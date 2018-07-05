#!/bin/bash

set -e

PACKAGE_NAME=gatehouse
NAMESPACE=gatehouse
VERSION=latest

docker login -u $DOCKER_REGISTRY_USER -p $DOCKER_REGISTRY_PASSWORD $DOCKER_REGISTRY_SERVER
docker tag gatehouse-release $DOCKER_REGISTRY_SERVER/$NAMESPACE/$PACKAGE_NAME:$VERSION
docker push $DOCKER_REGISTRY_SERVER/$NAMESPACE/$PACKAGE_NAME:$VERSION
