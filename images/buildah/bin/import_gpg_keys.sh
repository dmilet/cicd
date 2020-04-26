#!/bin/sh

INJECTED_GPG_SECREY_KEY_FILE=${INJECTED_GPG_KEY_FILE:-/vault/secrets/gpg-private-key.b64}
[[ -f $INJECTED_GPG_SECREY_KEY_FILE ]] && {
  cat  $INJECTED_GPG_SECREY_KEY_FILE | base64 -d | gpg2 --import
  gpg2 --list-secret-keys
}


INJECTED_GPG_PUBLIC_KEY_FILE=${INJECTED_GPG_KEY_FILE:-/vault/secrets/gpg-public-key.b64}
[[ -f $INJECTED_GPG_PUBLIC_KEY_FILE ]] && {
  cat  $INJECTED_GPG_PUBLIC_KEY_FILE | base64 -d | gpg2 --import
  gpg2 --list-keys
}

cat -
