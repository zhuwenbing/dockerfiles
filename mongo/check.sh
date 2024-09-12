#!/bin/sh
set -eo pipefail

host="$(hostname --ip-address || echo '127.0.0.1')"

for cmd in mongo mongosh; do
  if command -v "$cmd" >/dev/null; then
    if "$cmd" --quiet "$host/test" --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)'; then
      exit 0
    fi
  fi
done

exit 1
