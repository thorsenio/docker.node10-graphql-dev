#!/usr/bin/env bash

# Version 1.0.0

# This script mounts the project into a container that provides Node 10.14, Bash, and Git.
# By default the container starts with Bash. Pass a different command to the script
# to run that command instead in the container.
# Examples:
#   scripts/mount-project.sh npm ci
#   scripts/mount-project.sh npm run build
#
# For convenience, shortcuts are defined for common commands. E.g.,
#   scripts/mount-project.sh build
#   scripts/mount-project.sh serve
#   scripts/mount-project.sh test

# Defaults

# Read values from `.env`
source ../.env

# TODO: Read some of these values from `package.json`
DEFAULT_CMD=${DEFAULT_CMD:-'bash'}
GRAPHQL_SERVER_PORT=${GRAPHQL_SERVER_PORT:-'4000'}
DEFAULT_IMAGE_BASE_NAME=${ACCOUNT_NAME}/${PACKAGE_NAME}
IMAGE_BASE_NAME=${IMAGE_BASE_NAME:-'node10-graphql'}
PROJECT_ID=${PROJECT_ID:-'node10-graphql-app'}
WEB_SERVER_PORT=${WEB_SERVER_PORT:-'8080'}

# Generate a random ID to append to the container name
echoRandomId () {
  local LENGTH=4
  echo $(perl -pe 'binmode(STDIN, ":bytes"); tr/a-zA-Z0-9//dc;' < /dev/urandom | head -c 4)
}

# Constants

# Default command
CMD="${@:-${DEFAULT_CMD}}"

# Shortcut arguments
if [[ ${CMD} == 'build' ]]; then
  CMD='npm run build'
fi

if [[ ${CMD} == 'serve' ]]; then
  CMD="http-server -p ${WEB_SERVER_PORT} dist"
fi

# TODO: Make it easier to switch between production and nonproduction builds.
# The code below respects `NODE_ENV`, defaulting to `development` if NODE_ENV isn't set
if [[ ${CMD} == 'test' ]]; then
  CMD='npm run test'
  ENV='development'
else
  ENV=${NODE_ENV:-'development'}
fi

echo "Running container with command: ${CMD}"

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")
..

docker container run \
  --interactive \
  --rm \
  --tty \
  --env NODE_ENV=${ENV} \
  --expose ${WEB_SERVER_PORT} \
  --expose ${GRAPHQL_SERVER_PORT} \
  --mount type=bind,source=${PWD},target=/var/project \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  --name "${PROJECT_ID}-$(echoRandomId)" \
  --network washemapp_default \
  --publish ${GRAPHQL_SERVER_PORT}:${GRAPHQL_SERVER_PORT} \
  --publish ${WEB_SERVER_PORT}:${WEB_SERVER_PORT} \
  --workdir /var/project \
  ${IMAGE_BASE_NAME} \
  ${CMD}
