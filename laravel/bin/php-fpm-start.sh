#!/usr/bin/env bash

set -e -u -o pipefail

echo -e "[info]: performing initial secrets sync"
./bin/doppler-sync.sh

./bin/wait-for-it.sh "$(doppler secrets get DB_HOST --plain)":"$(doppler secrets get DB_PORT --plain)"

DB_FORCE_MIGRATE="$(doppler secrets get DB_FORCE_MIGRATE --plain)"
if [ "$DB_FORCE_MIGRATE" == 'yes' ]
then
    php artisan migrate --force
fi

echo -e "[info]: starting php-fpm"

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"
