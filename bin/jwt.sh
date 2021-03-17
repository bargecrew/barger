#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: ./bin/jwt.sh <payload.json>"
    exit 1
fi

payload_file="$1"

headers="$(cat data/auth/headers.json | jq -c . | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')"
payload="$(cat ${payload_file} | jq -c . | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')"

y="${headers}.${payload}"

mkdir -p tmp
cat .env | grep "JWT_PRIVATE_KEY=" | cut -d '=' -f2- | sed 's/\"//' | sed 's/\\n/\n/g' > ./tmp/jwt_private_key.pem

encrypted="$(echo -n ${y} | openssl dgst -sha256 -binary -sign ./tmp/jwt_private_key.pem | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')"

echo "${y}.${encrypted}"

exit 0
