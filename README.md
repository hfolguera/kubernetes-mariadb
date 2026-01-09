# kubernetes-mariadb

```
kubectl apply -f mariadb-namespace.yaml
kubectl create secret generic mariadb-root-pass -n mariadb --from-literal=password=<PASSWORD>
kubectl apply -f mariadb-statefulset.yaml
kubectl apply -f mariadb-service.yaml
```

