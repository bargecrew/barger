#!/bin/bash

set -euxo pipefail

cargo install cargo-watch

cargo install diesel_cli \
    --no-default-features \
    --features postgres

exit 0
