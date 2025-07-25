#! /bin/sh

if [ -n "${MYSQL_HOST}" ]; then
  node ./src/lib/database/wait.js
else
  echo "WARN: MYSQL_HOST is not defined."
fi

exec "$@"