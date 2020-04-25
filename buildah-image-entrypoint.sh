#!/bin/sh

INJECTED_GPG_KEY_FILE=${INJECTED_GPG_KEY_FILE:-/vault/secrets/gpg.txt}
[[ -f $INJECTED_GPG_KEY_FILE ]] && {
  cat  $INJECTED_GPG_KEY_FILE | base64 -d | gpg2 --import
  gpg2 --list-secret-keys
}

cat -
