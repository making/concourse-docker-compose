# Concourse + Vault on Docker Compose


## Install

```
brew install vault
brew install cloudfoundry/tap/bosh-cli
```

> BOSH cli is only used to generate certs

## Prepare certificats

### Generate self-signed certs

```
cd certs
./generate-certs.sh localhost.ik.am "*.localhost.ik.am"
cd ..
```

> `*.localhost.ik.am` will be resolved to `127.0.0.1`.

### Use Let's Encrypt

If you prefer "real certificates" by Let's Encrypt, ask @making.

## Launch docker compose

```
docker-compose up
```

## Initialize Vault

```
export VAULT_CACERT=$PWD/certs/ca.pem
export VAULT_ADDR=https://vault.localhost.ik.am:8200
vault operator init

vault operator unseal $UNSEAL_KEY_1
vault operator unseal $UNSEAL_KEY_3
vault operator unseal $UNSEAL_KEY_3
vault login $INITIAL_ROOT_TOKEN

vault secrets enable -version=1 -path=concourse kv
vault policy write concourse vault/concourse-policy.hcl
vault auth enable cert
vault write auth/cert/certs/concourse policies=concourse certificate=@certs/ca.pem ttl=1h
```

## Setup a pipeline

```
fly -t ws login -c https://concourse.localhost.ik.am -u test -p test --ca-cert certs/ca.pem
```

```
fly -t ws set-pipeline -p hello -c pipelines/hello.yml -n
fly -t ws unpause-pipeline -p hello
```

```
vault write concourse/main/secret value=Vault
```

```
fly -t ws trigger-job -j hello/hello-world -w
```
