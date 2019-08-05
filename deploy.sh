#!/bin/bash

set -e

REPOSITORY=pdr
PACKAGE_NAME=gatehouse
NAMESPACE=gatehouse
VERSION=latest
DOCKER_REGISTRY_SERVER=thomasvolk-docker-$REPOSITORY.bintray.io

docker login -u $DOCKER_REGISTRY_USER -p $DOCKER_REGISTRY_PASSWORD $DOCKER_REGISTRY_SERVER
docker tag gatehouse-release $DOCKER_REGISTRY_SERVER/$NAMESPACE/$PACKAGE_NAME:$VERSION
docker push $DOCKER_REGISTRY_SERVER/$NAMESPACE/$PACKAGE_NAME:$VERSION
