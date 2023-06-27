#!/usr/bin/env bash

if [[ -z "$DB_DIR" ]]; then
    echo "DB_DIR env var not specified - this should be a path of the directory where the database file should be stored"
    exit 1
fi
if [[ -z "$S3_DB_URL" ]]; then
    echo "S3_DB_URL env var not specified - this should be an S3-style URL to the location of the replicated database file"
    exit 1
fi

mkdir -p "$DB_DIR"

litestream restore -if-db-not-exists -if-replica-exists -o "$DB_DIR/db.sqlite" "$S3_DB_URL"

./manage.py collectstatic --noinput
./manage.py migrate --noinput
./manage.py createcachetable

chmod -R a+rwX /db

exec litestream replicate -config litestream.yml
