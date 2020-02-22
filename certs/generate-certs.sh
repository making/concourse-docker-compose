#!/bin/bash

set -e

DOMAIN=$1
shift
SANS=$@

_SANS="["
for san in ${SANS};do
  _SANS="$_SANS '$san',"
done
_SANS="$_SANS]"

bosh interpolate <(cat <<'EOF'
variables:
- name: default_ca
  type: certificate
  options:
    is_ca: true
    common_name: ca
- name: ssl
  type: certificate
  options:
    ca: default_ca
    common_name: ((domain))
    alternative_names: ((sans))
    organization: making
    extended_key_usage:
    - client_auth
    - server_auth    
EOF
) -v domain=${DOMAIN} -v sans="${_SANS}" --vars-store=creds.yml > /dev/null
bosh interpolate creds.yml --path /ssl/ca > ca.pem
bosh interpolate creds.yml --path /ssl/certificate > cert.pem
bosh interpolate creds.yml --path /ssl/private_key > key.pem

openssl x509 -in cert.pem -text -noout

rm -f creds.yml