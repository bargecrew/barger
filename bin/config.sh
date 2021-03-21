#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: ./bin/config.sh <config.json>"
    exit 1
fi

echo "[[profile]]"
echo "name = \"default\""
echo "url = \"http://localhost:8080\""
echo "token = \"$(./bin/jwt.sh ${1})\""

exit 0
