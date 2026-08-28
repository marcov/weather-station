import { mkdir, readFile, rename, writeFile } from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';
import { chromium } from 'playwright';

const renderWaitMs = 5_000;
const destinationDirectory = path.resolve(process.argv[2] || '/destdir');
const diagrams = [
    {
        url: 'https://www.wetterzentrale.de/en/show_diagrams.php?geoid=76406&model=ecm&var=93&run=0&lid=OP&bw=',
        filename: 'wz_meteogram.svg',
        format: 'highcharts-svg',
    },
    {
        url: 'https://www.wetterzentrale.de/en/show_diagrams.php?geoid=76406&model=ecm&var=201&run=12&lid=ENS&bw=',
        filename: 'wz_ensemble.png',
        format: 'image',
    },
];
const highchartsSource = await readFile(
    new URL('./node_modules/highcharts/highcharts.js', import.meta.url),
    'utf8',
);
const exportingSource = await readFile(
    new URL('./node_modules/highcharts/modules/exporting.js', import.meta.url),
    'utf8',
);

await mkdir(destinationDirectory, { recursive: true });

const browser = await chromium.launch({ headless: true });

try {
    for (const diagram of diagrams) {
        const destination = path.join(destinationDirectory, diagram.filename);
        const temporary = `${destination}.tmp-${process.pid}`;
        const page = await browser.newPage({ viewport: { width: 800, height: 600 } });

        await page.route('https://code.highcharts.com/10.3.3/highcharts.js', (route) => {
            return route.fulfill({ contentType: 'application/javascript', body: highchartsSource });
        });
        await page.route('https://code.highcharts.com/10.3.3/modules/exporting.js', (route) => {
            return route.fulfill({ contentType: 'application/javascript', body: exportingSource });
        });

        console.log(`loading ${diagram.url}`);
        await page.goto(diagram.url, { waitUntil: 'domcontentloaded', timeout: 60_000 });

        if (diagram.format === 'highcharts-svg') {
            await page.waitForSelector('.highcharts-root', {
                state: 'attached',
                timeout: 30_000,
            });
            await page.waitForTimeout(renderWaitMs);

            const svg = await page.locator('.highcharts-root').first().evaluate((element) => {
                const clone = element.cloneNode(true);
                if (!clone.hasAttribute('xmlns')) {
                    clone.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
                }
                return clone.outerHTML;
            });

            await writeFile(temporary, `<?xml version="1.0" encoding="UTF-8"?>\n${svg}\n`);
        } else {
            const image = page.locator('img[src*="ens_image.php"]').first();
            await image.waitFor({ state: 'attached', timeout: 30_000 });

            const imageUrl = new URL(await image.getAttribute('src'), page.url()).href;
            const response = await page.request.get(imageUrl);
            if (!response.ok()) {
                throw new Error(`failed to download ${imageUrl}: HTTP ${response.status()}`);
            }
            const contentType = response.headers()['content-type'] || '';
            if (!contentType.startsWith('image/png')) {
                throw new Error(`unexpected content type for ${imageUrl}: ${contentType}`);
            }
            await writeFile(temporary, await response.body());
        }

        await rename(temporary, destination);
        console.log(`saved ${destination}`);
        await page.close();
    }
} finally {
    await browser.close();
}
