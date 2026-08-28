import { mkdir, readFile, rename, writeFile } from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';
import { chromium } from 'playwright';

const diagramUrl = process.env.WZ_DIAGRAM_URL ||
    'https://www.wetterzentrale.de/en/show_diagrams.php?geoid=76406&model=ecm&var=93&run=0&lid=OP&bw=';
const renderWaitMs = Number(process.env.WZ_RENDER_WAIT_MS || 5_000);
const destination = path.resolve(process.argv[2] || '/destdir/wz_meteogram.svg');
const temporary = `${destination}.tmp-${process.pid}`;
const highchartsSource = await readFile(
    new URL('./node_modules/highcharts/highcharts.js', import.meta.url),
    'utf8',
);
const exportingSource = await readFile(
    new URL('./node_modules/highcharts/modules/exporting.js', import.meta.url),
    'utf8',
);

await mkdir(path.dirname(destination), { recursive: true });

const browser = await chromium.launch({ headless: true });

try {
    const page = await browser.newPage({ viewport: { width: 800, height: 600 } });

    await page.route('https://code.highcharts.com/10.3.3/highcharts.js', (route) => {
        return route.fulfill({ contentType: 'application/javascript', body: highchartsSource });
    });
    await page.route('https://code.highcharts.com/10.3.3/modules/exporting.js', (route) => {
        return route.fulfill({ contentType: 'application/javascript', body: exportingSource });
    });

    console.log(`loading ${diagramUrl}`);
    await page.goto(diagramUrl, { waitUntil: 'domcontentloaded', timeout: 60_000 });
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
    await rename(temporary, destination);
    console.log(`saved ${destination}`);
} finally {
    await browser.close();
}
