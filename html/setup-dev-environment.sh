#!/usr/bin/env bash

set -euo pipefail

readonly script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly port="${1:-8000}"

cd -- "${script_dir}"

./fetch-dev-assets.sh

printf '\nServing the development site at http://localhost:%s/\n' "${port}"
printf 'Responses are sent with browser caching disabled. Press Ctrl-C to stop.\n\n'

exec python3 - "${port}" <<'PYTHON'
import http.server
import sys


class NoCacheRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()


port = int(sys.argv[1])
server = http.server.ThreadingHTTPServer(("", port), NoCacheRequestHandler)

try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
finally:
    server.server_close()
PYTHON
