#!/bin/bash

set -euxo pipefail

./scripts/database.sh

cargo watch -x 'run --bin barger'

exit 0
