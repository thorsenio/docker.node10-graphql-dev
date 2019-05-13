#!/usr/bin/env bash

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

source .env

docker build \
  --build-arg PACKAGE_NAME=${PACKAGE_NAME} \
  --build-arg VERSION=${VERSION} \
  --file Dockerfile \
  --tag ${ACCOUNT_NAME}/${PACKAGE_NAME} \
  --tag ${ACCOUNT_NAME}/${PACKAGE_NAME}:${VERSION} \
  ..
