#!/bin/sh

#STORAGE="--storage-driver=vfs"
STORAGE=""
BUILDAH_CMD="buildah $STORAGE"

# $1 : full image name
# $2 : Dockerfile
# $3 : build context
$BUILDAH_CMD bud --squash --tag $1 -f $2 $3
container=$($BUILDAH_CMD from $1)

# re-commit as docker format (default is OCI)
$BUILDAH_CMD commit -f docker $container $1

$BUILDAH_CMD images

#$BUILDAH_CMD login -u $IMG_DEST_USR -p $IMG_DEST_PWD 
#$BUILDAH_CMD push $1
