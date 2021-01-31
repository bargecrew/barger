#!/bin/bash

set -euxo pipefail

./bin/database.sh

cargo watch -x 'run --bin barger'

exit 0
