#!/bin/sh

export GPG_KEY_ID="B54E53FEC26F2BC046D1A3A205EAAA8590B764DF"

export IMAGE_NAME="davidmilet/cicd:buildah-with-nexus-ingress-cert"

export IMG_SOURCE_HOSTNAME=""
export IMG_SOURCE_METHOD="containers-storage:"
export IMG_SOURCE_USR=""
export IMG_SOURCE_PWD=""

export IMG_DEST_HOSTNAME="docker.local"
export IMG_DEST_METHOD="docker://"
export IMG_DEST_USR="srvJenkins"
export IMG_DEST_PWD="Abcd1234"

export LOCAL_SIGSTORE="/var/local/sigstore"
export SIGSTORE_USR="srvJenkins"
export SIGSTORE_PWD="Abcd1234"
export SIGSTORE_SERVER="nexus.local"
export SIGSTORE_REPO_NAME="raw-sigstore-hosted"

./push_and_sign_image.sh
