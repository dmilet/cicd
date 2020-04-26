#!/bin/sh

GPG_KEY_ID=${GPG_KEY_ID:-B54E53FEC26F2BC046D1A3A205EAAA8590B764DF}

IMAGE_NAME=${IMAGE_NAME:-davidmilet/cicd:buildah-with-nexus-ingress-cert}


IMG_SOURCE_HOSTNAME=${IMG_SOURCE_HOSTNAME:-""}
IMG_SOURCE_METHOD=${IMG_SOURCE_METHOD:-"container-storage:"}
IMG_SOURCE_USR=${IMG_SOURCE_USR:-""}
IMG_SOURCE_PWD=${IMG_SOURCE_PWD:-""}
IMG_DEST_HOSTNAME=${IMG_DEST_HOSTNAME:-docker.local} 
IMG_DEST_METHOD=${IMG_DEST_METHOD:-"docker://"}
IMG_DEST_USR=${IMG_DEST_USR:-srvJenkins}
IMG_DEST_PWD=${IMG_DEST_PWD:-Abcd1234}

[[ $IMG_SOURCE_METHOD == "docker://" ]] && {
  [[ -z $IMG_SOURCE_HOSTNAME ]] && echo "IMG_SOURCE_HOSTNAME is empty" && exit 1
  [[ -z $IMG_SOURCE_USR ]] && echo "IMG_SOURCE_USR is empty" && exit 1
  [[ -z $IMG_SOURCE_PWD ]] && echo "IMG_SOURCE_PWD is empty" && exit 1
  podman login -u $IMG_SOURCE_USR -p $IMG_SOURCE_PWD $IMG_SOURCE_HOSTNAME
}

[[ $IMG_DEST_METHOD == "docker://" ]] && {
  [[ -z $IMG_DEST_HOSTNAME ]] && echo "IMG_DEST_HOSTNAME is empty" && exit 1
  [[ -z $IMG_DEST_USR ]] && echo "IMG_DEST_USR is empty" && exit 1
  [[ -z $IMG_DEST_PWD ]] && echo "IMG_DEST_PWD is empty" && exit 1
  podman login -u $IMG_DEST_USR -p $IMG_DEST_PWD $IMG_DEST_HOSTNAME
}

skopeo --debug copy --sign-by $GPG_KEY_ID \
	${IMG_SOURCE_METHOD}${IMG_SOURCE_HOSTNAME}/${IMAGE_NAME} \
	${IMG_DEST_METHOD}${IMG_DEST_HOSTNAME}/${IMAGE_NAME} \
	2>&1 | tee signature.log

LOCAL_SIGSTORE=${LOCAL_SIGSTORE:-/var/local/sigstore}
SIGSTORE_USR=${NEXUS_USR:-srvJenkins}
SIGSTORE_PWD=${SIGSTORE_PWD:-Abcd1234}
SIGSTORE_SERVER=${SIGSTORE_SERVER:-nexus.local}
SIGSTORE_REPO_NAME=${SIGSTORE_REPO_NAME:-raw-sigstore-hosted}

#SIGNATURE_FULL_FILE_NAME=/var/local/sigstore/davidmilet/cicd@sha256=696cd98732c2673be7656c7298b802581ca6dfbc8d71c707aac4081697b0d421/signature-1
SIGNATURE_FULL_FILE_NAME=$(grep "riting to " signature.log  | sed 's/Writing to /#/' | cut -d "#" -f 2 | sed 's/\"//')
SIGNATURE_DIRECTORY_NAME=$(dirname $SIGNATURE_FULL_FILE_NAME)
SIGNATURE_DIRECTORY_NAME=${SIGNATURE_DIRECTORY_NAME#$LOCAL_SIGSTORE}
SIGNATURE_FILE_NAME=$(basename $SIGNATURE_FULL_FILE_NAME)

curl --user ${SIGSTORE_USR}:${SIGSTORE_PWD} -X POST "https://${SIGSTORE_SERVER}/service/rest/v1/components?repository=${SIGSTORE_REPO_NAME}" \
	-H "accept: application/json" -H "Content-Type: multipart/form-data" \
	-F "raw.directory=${SIGNATURE_DIRECTORY_NAME}" \
	-F "raw.asset1=@${SIGNATURE_FULL_FILE_NAME};type=application/octet-stream" \
	-F "raw.asset1.filename=${SIGNATURE_FILE_NAME}"
