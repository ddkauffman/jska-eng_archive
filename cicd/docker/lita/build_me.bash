#!/bin/bash

set \
    -o errexit \
    -o pipefail \
    -o nounset \
    -o xtrace

exec \
docker builder build \
    --tag lita:latest \
    --build-arg ARG_RAVEN_SECRET_KEY=this_is_not_a_secret \
    --build-arg ARG_NAME_COLUMN='Telemetry Mnemonic' \
    --build-arg ARG_TIME_COLUMN='Observatory Time' \
    --build-arg ARG_VALUE_COLUMN='EU Value' \
    --file cicd/docker/lita/Dockerfile \
    .
