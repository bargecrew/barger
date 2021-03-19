#!/bin/bash

set -euxo pipefail

docker kill database || echo "No database running"
docker rm database || echo "No database exists"
docker run -d -p 5432:5432 \
    -e "POSTGRES_DB=barger" \
    -e "POSTGRES_USER=username" \
    -e "POSTGRES_PASSWORD=password" \
    --name database \
    postgres:13-alpine

sleep 5

(
    cd server;
    diesel migration run;
)

exit 0
