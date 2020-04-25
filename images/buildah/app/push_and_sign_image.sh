#!/bin/sh

# param1 : GPG KEY ID
# param2 : source image
# param3 : destination image

GPG_KEY_ID=$1
GPG_KEY_ID=${GPG_KEY_ID:-B54E53FEC26F2BC046D1A3A205EAAA8590B764DF}

IMG_SOURCE=$2
IMG_SOURCE=${IMG_SOURCE:-docker://docker.io/davidmilet/cicd:buildah-with-nexus-ingress-cert}

IMG_DEST=$3
IMG_DEST=${IMG_DEST:-docker://docker.local/davidmilet/cicd:buildah-with-nexus-ingress-cert} 

skopeo --debug copy --sign-by $GPG_KEY_ID $IMG_SOURCE $IMG_DEST 2>&1 | tee signature.log

LOCAL_SIGSTORE=${LOCAL_SIGSTORE:-/var/local/sigstore}

NEXUS_USR=${NEXUS_USR:-srvJenkins}
NEXUS_PWD=${NEXUS_PWD:-Abcd1234}
NEXUS_SERVER=${NEXUS_SERVER:-nexus.local}
SIGSTORE_REPO_NAME=${SIGSTORE_REPO_NAME:-raw-sigstore-hosted}

#SIGNATURE_FULL_FILE_NAME=/var/local/sigstore/davidmilet/cicd@sha256=696cd98732c2673be7656c7298b802581ca6dfbc8d71c707aac4081697b0d421/signature-1
SIGNATURE_FULL_FILE_NAME=$(grep "riting to " signature.log  | sed 's/Writing to /#/' | cut -d "#" -f 2 | sed 's/\"//')
SIGNATURE_DIRECTORY_NAME=$(dirname $SIGNATURE_FULL_FILE_NAME)
SIGNATURE_DIRECTORY_NAME=${SIGNATURE_DIRECTORY_NAME#$LOCAL_SIGSTORE}
SIGNATURE_FILE_NAME=$(basename $SIGNATURE_FULL_FILE_NAME)

curl --user ${NEXUS_USR}:${NEXUS_PWD} -X POST "https://${NEXUS_SERVER}/service/rest/v1/components?repository=${SIGSTORE_REPO_NAME}" \
	-H "accept: application/json" -H "Content-Type: multipart/form-data" \
	-F "raw.directory=${SIGNATURE_DIRECTORY_NAME}" \
	-F "raw.asset1=@${SIGNATURE_FULL_FILE_NAME};type=application/octet-stream" \
	-F "raw.asset1.filename=${SIGNATURE_FILE_NAME}"
