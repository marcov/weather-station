# Wetterzentrale SVG extractor

Extract the rendered ECMWF meteogram as a self-contained SVG and download the
Wetterzentrale ensemble PNG directly. Atomically replace `wz_meteogram.svg`
and `wz_ensemble.png` in the shared webshot volume.

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
node extract.mjs /tmp/wz-svg
```
