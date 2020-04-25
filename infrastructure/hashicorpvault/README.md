# installation
Create namespace and PV for vault
go to minikube (minikube ssh) and change permissions on /data/vault-volume so it's read/writable to userid 1000.
On minikube docker user has uid 1000, but on vault pod, vault user has uid 1000. Vault pod runs as uid 1000 and needs write access to /data/vault-volume

## install Vault
```
helm install vault --values helm-vault-values.yml -n vault-project \
    https://github.com/hashicorp/vault-helm/archive/v0.5.0.tar.gz
```
Follow instructions from https://learn.hashicorp.com/vault/getting-started-k8s/minikube 
Unseal the Vault
```
kubectl exec vault-0 -n vault-project -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json

$ cat cluster-keys.json
{
  "unseal_keys_b64": [
    "JnrtZ7k5eH6+Kt8tVyZF/zMTCLAdIQ2tDGSaq4UOkqU="
  ],
  "unseal_keys_hex": [
    "267aed67b939787ebe2adf2d572645ff331308b01d210dad0c649aab850e92a5"
  ],
  "unseal_shares": 1,
  "unseal_threshold": 1,
  "recovery_keys_b64": [],
  "recovery_keys_hex": [],
  "recovery_keys_shares": 5,
  "recovery_keys_threshold": 3,
  "root_token": "s.e4gTr58cxLJrcT8WxCFieCef"
}

VAULT_UNSEAL_KEY=JnrtZ7k5eH6+Kt8tVyZF/zMTCLAdIQ2tDGSaq4UOkqU=

$ kubectl exec vault-0 -n vault-project -- vault operator unseal $VAULT_UNSEAL_KEY
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.4.0
Cluster Name    vault-cluster-e8a88788
Cluster ID      6ebb59b5-e774-c977-b454-4ab933f37fa0
HA Enabled      false

$ kubectl get pods -n vault-project
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          7m44s
vault-agent-injector-86b8df8994-dt7wj   1/1     Running   0          7m44s

```

# ingress
```
kubectl create secret tls vault-tls --key tls.key --cert tls.crt --namespace vault-project

kubectl create -f vault-ingress.yaml -n vault-project

URL for UI : https://vault.local
URL for API: https://vault.local/v1
```


# login 
```
curl -X PUT -d @body https://vault.local/v1/auth/kubernetes/login
```
with body
```
"role" : "jenkins", "jwt" : "eyJhbGciOiJSUzI1NiIsImtpZCI6Ik5jdnZsM1VrbG83NW9YaEZBQW9VQXJkRGdwLVRYVzJhLU11VnRWVEhVUDAifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJqZW5raW5zLXByb2plY3QiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiYnVpbGRhZ2VudC10b2tlbi02c25jOCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJidWlsZGFnZW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYjhiNTQ4MDctNTgzMC00YmYwLThhNjEtODczZDc4YTZjZTk3Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmplbmtpbnMtcHJvamVjdDpidWlsZGFnZW50In0.ltjf1ALc85Acsb9sqJVazoGYzsgvsaRItmEhCNAtY4QU2XN9DkfObQO3l_obullBibyi_QO5wl9rMYHZBNO-dXcLkrqMtM8ktuYKMGOh686WLG950ipNzZZblOUsmymMLYo0gMFwvEPHEMefEibZ9nXXUaOp9APlQjzp7-yowppcGNcKBT3xnMD5VFQpQAwWPDU_-icrqvlk6zI57e3xd-s_1zqX9dawb_TDqOIcgprcOZ2FVhFQ5urrDj5p-erDF3ajgwkMhVxUN1kaUomhgXfBp_s1J9xAfLZuonoWFmf1cH6VwD4xyOFaYcItBukeV8lB_wCt6O4BQRteUOH03Q" }
```
jwt is the "token" from /var/run/secrets/kubernetes.io/serviceaccount/token
```
"request_id":"0ae816ff-de13-6378-42d3-661ea025ed48","lease_id":"","renewable":false,"lease_duration":0,"data":null,"wrap_info":null,"warnings":null,"auth":{"client_token":"s.vLWYDkWd5Z3XeTN9TZOXD2pM","accessor":"JFcGFJ8k8E1LpQpAEo9NoNSW","policies":["default","jenkins"],"token_policies":["default","jenkins"],"metadata":{"role":"jenkins","service_account_name":"buildagent","service_account_namespace":"jenkins-project","service_account_secret_name":"buildagent-token-6snc8","service_account_uid":"b8b54807-5830-4bf0-8a61-873d78a6ce97"},"lease_duration":86400,"renewable":true,"entity_id":"73474dfd-34ae-67ce-9e0a-2394c303a3e4","token_type":"service","orphan":true}}
```
```
client_token=s.vLWYDkWd5Z3XeTN9TZOXD2pM
```
# retrieve secret
```
curl -X GET -H "X-Vault-Token: s.vLWYDkWd5Z3XeTN9TZOXD2pM" https://vault.local/v1/secret/data/jenkins/config
```
```
{"request_id":"72af7180-911c-29b3-4898-b91f3bdcf968","lease_id":"","renewable":false,"lease_duration":0,"data":{"data":{"password":"static-password","username":"static-user"},"metadata":{"created_time":"2020-04-24T15:40:51.521672974Z","deletion_time":"","destroyed":false,"version":1}},"wrap_info":null,"warnings":null,"auth":null}
```


# retrieve wrapped secret, single use token
Token will be valid for one minute only
```
curl -X GET -H "X-Vault-Token: s.ARxZZR0crA4NF454XN9Zs0N2" -H "X-Vault-Wrap-TTL: 1m" https://vault.local/v1/secret/data/jenkins/config
```

# unwrap
```
curl -X POST -H "X-Vault-Token: s.GKqKp4IK43Ebk70OL6ndMWg2" https://vault.local/v1/sys/wrapping/unwrap
```

