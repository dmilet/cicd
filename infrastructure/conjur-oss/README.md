# installation
```

kubectl create -f conjur-namespace.yaml
kubectl create -f conjur-volume.yaml

# https://github.com/cyberark/conjur-oss-helm-chart/tree/master/conjur-oss

helm install conjur-oss -f conjur-values.yaml -n conjur-project \
https://github.com/cyberark/conjur-oss-helm-chart/releases/download/v1.3.8/conjur-oss-1.3.8.tgz

# Additional service to expose directly http port from pod
kubectl create -f conjur-service-http.yaml

# nginx-ingress takes a https in, then sends to http service
kubectl create -f conjur-ingress.yaml
```

# uni-installation
helm uninstall conjur-oss -n conjur-project


# First time configuration
```
$ kubectl get pods -n conjur-project
NAME                                  READY   STATUS    RESTARTS   AGE
conjur-oss-6bc89b4bd6-mk5v6           2/2     Running   4          83m
conjur-oss-postgres-79cfd687d-98t97   1/1     Running   2          83m

OWNER@E5430-DELL MINGW64 ~
$ export POD_NAME=conjur-oss-6bc89b4bd6-mk5v6


OWNER@E5430-DELL MINGW64 ~
$ kubectl exec $POD_NAME --container=conjur-oss conjurctl account create "default" -n conjur-project
Created new account 'default'
Token-Signing Public Key: -----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6eirycCV4tL2k3lxge49
YBoEMJUpmmfNpy23sDNpr7HCv1XL4npou1ivJ6Bx6pJag6m5uXxf+b8bG0ZOqcaN
RkjTpDgdydAi2xPNwRWpTRLyzU92ht/zS+A/8wf2zLGyquBX4jYHS7s6TfDXwKSQ
2+0G/0YLwCXZ5+/Ir/ug4P0qkv7YtQJT8lNNG7MX5OP8OdOGWaPNXAn23CphP4vo
E4G1gsjvEtYXEizWwmXi7TV1kRy0tsLuyCBfgDJFw57J0AXfS/pBjzyAK/kgcbnA
JHMqvmM7rbS2PQmsANWaJA2wxBv9cYXy151KL20vkyoACkgjkXRGzpkHH1tnOe0C
QwIDAQAB
-----END PUBLIC KEY-----
API key for admin: a7yhe72eyv8z2r2hrsjf1s7r2x5fk8g37qynw81q9hzw83tfqxx3
```


# conjur-cli
On a VM with podman installed

cd ~
mkdir .conjur-cli
alias conjur="docker run --rm -it -v $(pwd)/.conjur-cli:/root cyberark/conjur-cli:5-latest"

conjur init -u https://conjur.local -a "default"
conjur authn login -u admin -p a7yhe72eyv8z2r2hrsjf1s7r2x5fk8g37qynw81q9hzw83tfqxx3
conjur authn whoami

{"account":"default","username":"admin"}

# Create policy
conjur policy load root policy/signer-policy.yml > signer_tokens
