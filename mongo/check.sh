#!/bin/sh
set -eo pipefail

host="$(hostname --ip-address || echo '127.0.0.1')"

if [[ -n $( command -v mongo ) ]]; then
  if mongo --quiet "$host/test" --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)'; then
    exit 0
  fi
elif [[ -n $( command -v mongosh ) ]]; then
  if mongosh --quiet "$host/test" --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)'; then
    exit 0
  fi
fi

exit 1
