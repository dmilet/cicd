#!/bin/sh
# load the certs injected as volume
update-ca-trust

# import the 
/usr/local/bin/import_gpg_keys.sh

cat -
