#!/bin/bash

set -euxo pipefail

./bin/database.sh

cargo watch -x 'run --bin server'

exit 0
