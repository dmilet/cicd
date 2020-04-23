# installation
```

kubectl create -f conjur-namespace.yaml
kubectl create -f conjur-volume.yaml


helm install conjur-oss -f conjur-values.yaml -n conjur-project \
https://github.com/cyberark/conjur-oss-helm-chart/releases/download/v1.3.8/conjur-oss-1.3.8.tgz

# Additional service to expose directly http port from pod
kubectl create -f conjur-service-http.yaml

# nginx-ingress takes a https in, then sends to http service
kubectl create -f conjur-ingress.yaml
```

# uni-installation
helm uninstall conjur-oss -n conjur-project


