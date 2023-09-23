#!/bin/bash

# https://github.com/mozilla/sops/

# generate gpg key used by sops
export KEY_NAME="automation-gpg-key"
export KEY_COMMENT="gpg key used in automation"
gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${KEY_COMMENT}
Name-Real: ${KEY_NAME}
EOF

# How to encrypt/decrypt dotenv files
gpg --list-secret-keys "${KEY_NAME}"
export KEY_FP=GPG_KEY_ID
sops --encrypt --input-type dotenv --output-type dotenv \
    --encrypted-regex '^(DBUsername|BPassword)$' \
    --pgp GPG_KEY_ID \
    dev/backend > dev/backend-encrypted

sops --decrypt --input-type dotenv --output-type dotenv \
    --encrypted-regex '^(BUsername|DBPassword)$' \
    --pgp GPG_KEY_ID \
    dev/backend.enc > dev/backend-decrypted

# How to encrypt/decrypt YAML files
sops --encrypt --in-place --encrypted-regex 'password|pin' --pgp GPG_KEY_ID test.yaml
sops --encrypt --in-place --pgp GPG_KEY_ID  cluster/development/dbconnection-secret.yaml
sops --encrypt --in-place --encrypted-regex 'password|pin' --pgp `gpg --fingerprint "automation" | grep pub -A 1 | grep -v pub | sed s/\ //g` test.yaml
sops --decrypt test.yaml

# How to import/export keys
gpg --export -a "automation" > public.key
gpg --export-secret-key -a "automation" > private.key
gpg --import public.key
gpg --allow-secret-key-import --import private.key


# Cluster with FluxCD - bootstrap example
export KEY_NAME="tenant_name-tenant_id"
export KEY_COMMENT="tenant-tenant_name-tenant_id"
gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${KEY_COMMENT}
Name-Real: ${KEY_NAME}
EOF
gpg --list-secret-keys "${KEY_NAME}"
export KEY_FP="KEY_ID"
gpg --export-secret-keys --armor "${KEY_FP}" |
kubectl create secret generic sops-gpg \
    --namespace=flux-system \
    --from-file=sops.asc=/dev/stdin
gpg --export --armor "${KEY_FP}" > ./clusters/tenant_name-dev/.sops.pub.asc

# test sops
kubectl create secret generic  backend-dbconnstr --from-file=connection=../temp/test-secret \
    -n development --dry-run=client \
    -o yaml > apps/cluster/development/dbconnection-secret.yaml
sops --encrypt --in-place --pgp KEY_ID  apps/cluster/backend/development/dbconnection-secret.yaml
sops --encrypt --in-place  --encrypted-regex 'token' --pgp KEY_ID ./secret-token.yaml
sops -d -i --pgp --encrypted-regex 'stringData' $GPG_KEY_ID ./secrets.yaml
