# Wetterzentrale SVG extractor

This is intentionally separate from the existing PhantomJS-based webshot
image. It extracts the rendered ECMWF Highcharts diagram as a self-contained
SVG and atomically replaces `wz_meteogram.svg` in the shared webshot volume.

Build from the repository root:

```bash
podman build -t "pullme/$(uname -m)-wz-svg:latest" \
    -f apps/wz-svg/Dockerfile .
```

Run locally after installing the browser once:

```bash
cd apps/wz-svg
npm ci
npx playwright install chromium
node extract.mjs /tmp/wz_meteogram.svg
```
