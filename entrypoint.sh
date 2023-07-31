#!/usr/bin/env bash

set -eo pipefail

if [ -n "${DEBUG:-}" ]; then
    set -x
fi

exec "$@"
