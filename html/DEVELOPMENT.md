# Local development

The tracked HTML and CSS files are the production files. Local weather data,
charts, webcam images, and forecast snapshots are downloaded into ignored
directories that reproduce the nginx URL layout without entering a deployment
commit.

Refresh the local snapshots and start the no-cache development server:

```bash
./setup-dev-environment.sh
```

The default address is <http://localhost:8000/>. To use another port, pass it
as the first argument:

```bash
./setup-dev-environment.sh 8080
```

The external font, JavaScript, and Meteoblue forecast widget still require
Internet access. A failed download is reported as `missing`; any older
successful snapshot at that path is preserved. Weather data remains a local
snapshot; stop and rerun the script when you want to refresh it.

Before committing, use `git status --short` to confirm that only intentional
source changes are tracked. The downloaded snapshot directories are listed in
this directory's `.gitignore`.
