#!/bin/bash

set -euxo pipefail

RUSTFLAGS="-Dwarnings" cargo clippy

exit 0
