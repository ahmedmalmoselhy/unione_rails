#!/bin/sh
set -e

rm -f /app/tmp/pids/server.pid

if [ "${RAILS_ENV}" = "production" ]; then
  bundle exec rails db:prepare
fi

exec "$@"
