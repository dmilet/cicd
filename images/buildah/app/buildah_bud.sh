#!/bin/sh

STORAGE="--storage-driver=vfs"
BUILDAH_CMD="buildah $STORAGE"

# $1 : full image name
# $2 : Dockerfile
# $3 : build context
container=$($BUILDAH_CMD bud --squash --tag $1 -f $2 $2)

#container=$($BUILDAH_CMD from $1)
$BUILDAH_CMD commit -f docker $container $1

