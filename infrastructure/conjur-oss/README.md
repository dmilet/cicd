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
alias conjur='docker run --rm -it -v ~/.conjur-cli:/root -v $(pwd):/data cyberark/conjur-cli:5-latest'

conjur init -u https://conjur.local -a "default"
conjur authn login -u admin -p a7yhe72eyv8z2r2hrsjf1s7r2x5fk8g37qynw81q9hzw83tfqxx3
conjur authn whoami

{"account":"default","username":"admin"}

# Create policy
conjur policy load root policy/signer-policy.yml > signer_tokens

```
$ cat signer_tokens
Loaded policy 'root'
{
  "created_roles": {
    "default:user:signer-admin@signer": {
      "id": "default:user:signer-admin@signer",
      "api_key": "24yb3td13sf9nb2eg2vygj5gh632ngsk63f4j9sa1vjwpjq38h5pw4"
    },
    "default:host:signer/signer-app": {
      "id": "default:host:signer/signer-app",
      "api_key": "3vyzkb01p3d7xr3q26krz3v01fzr12bxn6s2ayx5cen4a3v32kgmszb"
    }
  },
  "version": 1
}
```

# create secret value
```
secretVal=$(openssl rand -hex 12 | tr -d '\r\n')
conjur variable values add signer/secretVar $secretVal
conjur variable value signer/secretVar
```

# Get Token
The user is host/signer/signer-app, which is URL-encoded as `host%2Fsigner%2Fsigner-app`
```
curl -v -d "3vyzkb01p3d7xr3q26krz3v01fzr12bxn6s2ayx5cen4a3v32kgmszb" https://conjur.local/authn/default/host%2Fsigner%2Fsigner-app/authenticate
```

The output is a JWT token which is valid for 8 minutes
```
{"protected":"eyJhbGciOiJjb25qdXIub3JnL3Nsb3NpbG8vdjIiLCJraWQiOiI2OTkyMWQxM2Y0MTc3ZWI2Y2VlNTk4MjU2ZTViNzA5MyJ9","payload":"eyJzdWIiOiJob3N0L3NpZ25lci9zaWduZXItYXBwIiwiaWF0IjoxNTg3NjczNzY3fQ==","signature":"u6nbaNnKhcmMZsqVAI59q1TADU7GB9qnWw6WLcvoXy-TCrG7H60oHEkzqW-siRu6KEAKge3vCsHd3p4Zmjetqyi-Np7buZyzsEE63s0NQyy6OaCXBNrtVnohwQlxmiOmu-z_7cisw6mhjQAaX1P4NcsgcU5ugKPpN4rL8CbSzxuGw8SY2wUJrSEqL8FmoAFspOhvDSipHATVFN4HuyrckNioR2GFRQ7lB1gAegQW1t7DnJ91AyHC8vUqtvJEU0b4HmOM5Y9cYtitj3jtNWnldGztkC7px_2qjzHE1JZ3gtSI3avF_bC7f0DSdhvqIUU-pwD2aluvXByrn31gz-qL3UL7iLrYtSxxlEtKjiD3hkyNfElW_gXaQQdYCGOz471R"}
```



# Jenkins configuration
```
$ conjur policy load root data/jenkins-policy.yml
Loaded policy 'root'
{
  "created_roles": {
    "default:user:jenkins-so@jenkins": {
      "id": "default:user:jenkins-so@jenkins",
      "api_key": "2vks6rx3vys68a3nh98783bz4m4mvxmcfr2gvjejf2r3zfsa33m4zy2"
    },
    "default:host:jenkins/jenkins.local": {
      "id": "default:host:jenkins/jenkins.local",
      "api_key": "2t1xwtd2sf3pzw2z5xyfk2wjpya13p33g7d147s1ag2gyq94z2ah59z8"
    }
  },
  "version": 8
}
[david@localhost policy]$
```


