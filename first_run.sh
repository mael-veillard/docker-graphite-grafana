#!/bin/bash

# system is already configured, terminate
if grep -q '@DB_USER@' /etc/grafana/grafana.ini; then

    [ -z "$PGPASSWORD" ] && exit 1
    [ -z "$PGHOST" ] && exit 1
    [ -z "PGUSER" ] && exit 1

    DB_USER="${DB_USER:-graphite}"
    DB_PASSWORD="${DB_PASSWORD:-graphite}"
    DB_GRAPHITE_NAME="${DB_GRAPHITE_NAME:-graphite}"
    DB_GRAFANA_NAME="${DB_GRAFANA_NAME:-grafana}"
    DB_HOST="${DB_HOST:-postgres}"
    DB_PORT="${DB_PORT:-5432}"

    for CONFIG_FILE in /etc/grafana/grafana.ini /etc/graphite/local_settings.py; do
        sed -i -e "s/@DB_USER@/$DB_USER/" \
               -e "s/@DB_PASSWORD@/$DB_PASSWORD/" \
               -e "s/@DB_HOST@/$DB_HOST/" \
               -e "s/@DB_PORT@/$DB_PORT/" \
               -e "s/@DB_GRAFANA_NAME@/$DB_GRAFANA_NAME/" \
               -e "s/@DB_GRAPHITE_NAME@/$DB_GRAPHITE_NAME/" $CONFIG_FILE
    done

    if ! psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
        psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
    fi

    for DB_NAME in $DB_GRAPHITE_NAME $DB_GRAFANA_NAME; do
        if ! psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
            psql -c "CREATE DATABASE $DB_NAME;"
            psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME to $DB_USER;"
        fi
    done

    [ "$(ls -A /var/lib/graphite/whisper)" ] || graphite-manage syncdb --noinput
fi

exec /usr/bin/supervisord
