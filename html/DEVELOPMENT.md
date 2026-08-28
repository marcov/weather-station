# Local development

The tracked HTML and CSS files are the production files. Local weather data,
charts, webcam images, and forecast snapshots are downloaded into ignored
directories that reproduce the nginx URL layout without entering a deployment
commit.

Refresh the local snapshots from the live site:

```bash
./fetch-dev-assets.sh
```

Then serve this directory:

```bash
python3 -m http.server
```

Open <http://localhost:8000/>. The external font, JavaScript, forecast widget,
and live-image URLs still require Internet access. A failed download is reported
as `missing`; any older successful snapshot at that path is preserved.

Before committing, use `git status --short` to confirm that only intentional
source changes are tracked. The downloaded snapshot directories are listed in
this directory's `.gitignore`.
