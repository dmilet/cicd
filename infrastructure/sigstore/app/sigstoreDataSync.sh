#!/bin/sh

NEXUS_HOSTNAME=${NEXUS_HOSTNAME:-nexus.local}
SIGSTORE_REPO_NAME=${REPOSITORY_NAME:-sigstore}

SIGSTORE_EXTRACT_LOCATION=${SIGSTORE_EXTRACT_LOCATION:-/tmp}


# retrieve most recent file from Nexus

http_code=$(curl -o /tmp/sigdata_list.json.$$ -s -w "%{http_code}" -X GET "https://nexus.local/service/rest/v1/search/assets?sort=name&direction=desc&repository=sigstore" -H "accept: application/json")
rc=$?
[[ $rc -ne 0 ]] && echo "[FATAL] Failed to execute curl. Exit code $rc" && exit $rc
[[ $http_code -ne 200 ]] && echo "[FATAL] curl received HTTP_CODE $http_code" && exit 1


downloadUrl=$(cat /tmp/sigdata_list.json.$$ | jq .items[0].downloadUrl | sed 's/\"//g')
filename=$(cat /tmp/sigdata_list.json.$$ | jq .items[0].path | sed 's/\"//g')

rm  /tmp/sigdata_list.json.$$

http_code=$(curl -o /tmp/$filename -s -w "%{http_code}" -X GET $downloadUrl)
rc=$?
[[ $rc -ne 0 ]] && echo "[FATAL] Failed to execute curl. Exit code $rc" && exit $rc
[[ $http_code -ne 200 ]] && echo "[FATAL] curl received HTTP_CODE $http_code" && exit 1


tar 
 
exit 0

