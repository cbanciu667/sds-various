#!/bin/bash

# https://developer.hashicorp.com/vault/docs/install


# vault initial commands
export VAULT_ADDR='http://127.0.0.1:8200'
vault login ROOT_TOKEN -address="http://192.168.1.2:8200"
vault operator unseal

# insert value with remove command
vault write -address="http://192.168.1.2:8200" auth/userpass/users/bob password="long-password"

# add policy
vault policy write example-policy .\vault\example_policy.hcl

# enable secret path when starting in production mode (namespaces not allowed in FREE version)
vault secrets enable -path="secret" kv

# create token
vault token create -policy=example-policy -display-name TOKEN_NAME

# login with specific token
vault login TOKEN

# put secrets
vault kv put secret/AWS_S3 AWS_ACCESS_KEY_ID=AWS_KEY_ID AWS_SECRET_KEY_ID=AWS_SECRET_KEY

# get secrets
vault kv get secret/AWS_S3

# create namespace (ONLY in Enterprise version)
vault namespace create -address="http://192.168.1.2:8200" MY_NAMESPACE/

# other vault commands examples
vault kv put secret/foo bar=precious
vault kv get secret/foo
vault kv enable-versioning secret/
vault kv put secret/foo bar=copper
vault kv get -version=1 secret/foo
vault kv get -version=2 secret/foo
vault kv delete secret/foo
vault kv delete -versions=1 secret/foo
vault kv undelete -versions=1 secret/foo
vault kv destroy -versions=1 secret/foo

# API commands examples
export VAULT_TOKEN=VAULT_TOKEN
curl \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{ "data": { "foo": "world" } }' \
    http://127.0.0.1:8200/v1/secret/data/hello

curl \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -X GET \
    http://127.0.0.1:8200/v1/secret/data/hello

curl \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -X GET \
    http://127.0.0.1:8200/v1/secret/data/hello

# vault policy - second example
# vault/policies/app-policy.json
# {
#   "path": {
#     "secret/data/app/*": {
#       "policy": "read"
#     }
#   }
# }
vault policy write app /vault/policies/app-policy.json
vault token create -policy=app
