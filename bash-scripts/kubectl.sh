#!/bin/bash

KUBE_EDITOR="nano" kubectl -n kube-system edit deployment kubernetes-dashboard (add   - --token-ttl=36000)

# EBS
kubectl patch pv jhooq-pv -p '{"metadata":{"finalizers":null}}'
kubectl patch pvc jhooq-pv-claim -p '{"metadata":{"finalizers":null}}'
kubectl patch storageclass jhooq-pv-storage-class -p '{"metadata":{"finalizers":null}}'
kubectl delete pvc --grace-period=0 --force --namespace mynamespace jhooq-pv-claim
kubectl delete pv --grace-period=0 --force --namespace mynamespace jhooq-pv
kubectl delete storageclass --grace-period=0 --force --namespace mynamespace jhooq-pv-storage-class

# secrets
kubectl create secret generic example-dbconnection --from-file=connection=./example-secret -n development-k8s
kubectl delete secret example-dbconnection -n development-k8s
kubectl describe secret example-dbconnection -n development-k8s
kubectl create secret generic db-user-pass --from-literal=username=devuser --from-literal=password='SecretPassword'
kubectl get secret db-user-pass -o jsonpath='{.data}'
echo'SecretPassword'| base64 --decode
# REMARK: use echo -n "SECRET" | base64 during secret creation. Otherwise \n will be added.

# svc
kubectl create serviceaccount SVC_NAME
kubectl create rolebinding SVC_NAME-admin-default  --clusterrole=cluster-admin   --serviceaccount=default:SVC_NAME
kubectl create clusterrolebinding serviceaccounts-cluster-admin-SVC_NAME --clusterrole=cluster-admin --group=system:serviceaccount:default:SVC_NAME
kubectl create clusterrolebinding BINDING_NAME   --clusterrole=cluster-admin   --serviceaccount=kube-system:default

# cluster info
kubectl api-versions >> rbac.authorization.k8s.io/v1
kubectl cluster-info dump | grep authorization-mode


# pods
kubectl get pods -n NAMESPACE
kubectl get pods --all-namespaces
kubectl get pod -l app=APP_LABEL
kubectl get pod --show-label
kubectl get pod POD -n NAMESPACE -o go-template="{{range .status.containerStatuses}}{{.lastState.terminated.message}}{{end}}"
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName -n NAMESPACE
kubectl get pod POD -n NAMESPACE --output=yaml
kubectl label pods secure-monolith "secure=enabled"
kubectl port-forward POD_NAME 10080:80
kubectl run --image=nginx nginx-server --port=80 --env="DOMAIN=cluster"
kubectl run -it --rm load-generator --image=busybox /bin/sh
kubectl run nginx --image=nginx:1.10.0
kubectl -n NAMESPACE exec-as -u root --stdin --tty POD_NAME -- sudo yum install stress -y && /bin/
kubectl run my-shell --rm -i --tty --image ubuntu -- 
kubectl describe pods POD_NAME -- get debug information about pods (checks status also during deployments)
kubectl top POD -n NAMESPACE
kubectl exec -it POD_NAME /bin/ -n NAMESPACE

# events
kubectl get ev -w -n ci-cd
kubectl get ev -w --all-namespaces
kubectl get events --sort-by='.metadata.creationTimestamp' -n NAMESPACE
kubectl get ev -w -n NAMESPACE --sort-by=.metadata.creationTimestamp -A

# logs
kubectl logs -n NAMESPACE POD_NAME -f
kubectl logs POD_NAME CONTAINER_NAME -n NAMESPACE --previous
kubectl logs POD_NAME  CONTAINER_NAME -n NAMESPACE
kubectl logs -f -c CONTAINER_NAME POD_NAME -n project-zero
kubectl logs --namespace argocd --selector app.kubernetes.io/name=argocd-image-updater --follow