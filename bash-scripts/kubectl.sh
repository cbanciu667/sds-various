#!/bin/bash

KUBE_EDITOR="nano" kubectl -n kube-system edit deployment kubernetes-dashboard (add   - --token-ttl=36000)

# generic kubectl commands examples
kubectl get hpa -w --all-namespaces
kubectl get clusterissuer --all-namespaces
kubectl get replicasets
kubectl get namespaces
kubectl get nodes
kubectl get issuer --all-namespaces
kubectl get certificate --all-namespaces
kubectl get order --all-namespaces
kubectl config set-credentials cluster-admin --token=bearer_token
kubectl config use-context docker-for-desktop
kubectl describe certificate example-wildcard-cert -n kube-system
kubectl logs -n kube-system -l app=cert-manager -c cert-manager
kubectl describe clusterissuer letsencrypt-staging -n kube-system
kubectl describe clusterissuer test-selfsigned -n certmanager-test
kubectl describe certificate selfsigned-cert  -n cert-manager-test
kubectl get ing -n ci-cd
kubectl describe ing jenkins -n ci-cd
kubectl api-versions
kubectl cluster-info dump | grep authorization-mode

# secrets
kubectl create secret generic example-dbconnection --from-file=connection=./example-secret -n development-k8s
kubectl delete secret example-dbconnection -n development-k8s
kubectl describe secret example-dbconnection -n development-k8s
kubectl create secret generic db-user-pass --from-literal=username=devuser --from-literal=password='SecretPassword'
kubectl get secret example-wildcard-cert-tls --namespace=kube-system --export -o yaml |  rancher kubectl apply --namespace=ci-cd -f -
kubectl get secret gitlab-registry --namespace=revsys-com --export -o yaml | kubectl apply --namespace=devspectrum-dev -f -
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | awk '/^deployment-controller-token-/{print $1}') | awk '$1=="token:"{print $2}'
kubectl get secret db-user-pass -o jsonpath='{.data}'
echo'SecretPassword'| base64 --decode
# REMARK: use echo -n "SECRET" | base64 during secret creation. Otherwise \n will be added.

# svc
kubectl create serviceaccount SVC_NAME
kubectl create rolebinding SVC_NAME-admin-default  --clusterrole=cluster-admin   --serviceaccount=default:SVC_NAME
kubectl create clusterrolebinding serviceaccounts-cluster-admin-SVC_NAME --clusterrole=cluster-admin --group=system:serviceaccount:default:SVC_NAME
kubectl create clusterrolebinding BINDING_NAME   --clusterrole=cluster-admin   --serviceaccount=kube-system:default

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

# deployments
kubectl expose deployment nginx-server --port=80 --name=nginx-http -type LoadBalancer
kubectl apply -f DEPLOYMENT_NAME.yaml --record
kubectl rollout status deployment DEPLOYMENT_NAME
kubectl delete -f DEPLOYMENT_NAME.yaml
kubectl rollout history deployment DEPLOYMENT_NAME
kubectl get deployment --namespace=kube-system
kubectl describe deployments DEPLOYMENT_NAME -n NAMESPACE
kubectl set env deployment/registry STORAGE_DIR=/local
kubectl scale --replicas=3 deployment/hello-nginx

# config maps
kubectl create configmap nginx-proxy-conf --from-file ./nginx/proxy.conf
kubectl describe configmap nginx-proxy-conf
kubectl create configmap prometheus-scrapper-config --from-file=scrapper-config.json -n maintenance

# dns resolution
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl get pods dnsutils
kubectl exec -i -t dnsutils -- nslookup kubernetes.default
kubectl exec -ti dnsutils -- cat /etc/resolv.conf
kubectl exec -i -t dnsutils -- nslookup kubernetes.default
kubectl get pods --namespace=kube-system -l k8s-app=kube-dns
kubectl exec -i -t dnsutils -- nslookup postgresql-headless.database.svc.cluster.local

# jobs
kubectl create job --from=cronjob/ecr-credentials-sync ecr-credentials-sync-001 -n flux-system
kubectl get ev -n flux-system --sort-by='.lastTimestamp'

# custom metrics API queries
kubectl api-versions | grep metrics
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/name" -n NAMESPACE  | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/NAMESPACE/pods/*/io_dropwizard_jetty_MutableServletContextHandler_active_requests" -n NAMESPACE  | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/NGINX_INGRESS_NAMESPACE/ingresses/INGRESS_NAME/nginx_ingress_controller_requests" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq . | grep ingresses.extensions
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/NAMESPACE/ingresses.extensions/zero-service-test-hpa/hpa_nginx_ingress_controller_requests_per_second" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/NGINX_INGRESS_NAMESPACE/ingresses/zero-service-test-hpa/nginx_ingress_controller_requests" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/packets-per-second"

# volumes
kubectl patch pv jhooq-pv -p '{"metadata":{"finalizers":null}}'
kubectl patch pvc jhooq-pv-claim -p '{"metadata":{"finalizers":null}}'
kubectl patch storageclass jhooq-pv-storage-class -p '{"metadata":{"finalizers":null}}'
kubectl delete pvc --grace-period=0 --force --namespace mynamespace jhooq-pv-claim
kubectl delete pv --grace-period=0 --force --namespace mynamespace jhooq-pv
kubectl delete storageclass --grace-period=0 --force --namespace mynamespace jhooq-pv-storage-class

# performance monitoring with krew plugin
# https://krew.sigs.k8s.io/plugins/
kubectl krew install resource-capacity view-allocations
kubectl resource-capacity --pods --util
kubectl view-allocations -u
watch kubectl top pod -n development

# fix removal of nginx ingress
kubectl patch ingress  -n development web-bff-svc-ingress -p '{"metadata":{"finalizers":[]}}' --type=merge

# force removal of PODS in status TERMINATING
kubectl delete pod elasticsearch-master-1 --grace-period=0 --force --namespace efk

# SA permissions
kubectl auth can-i list pods --as=system:serviceaccount:dev:aws-data-processing-sa -n dev
kubectl auth can-i --list --as=system:serviceaccount:dev:aws-data-processing-sa -n dev

# port forwarding
kubectl -n dev port-forward svc/mongodb-mongodb-dev 27017:27017

# fix namespace stuck in termination
kubectl get namespace ${NAMESPACE} -o json > tmp.json
nano tmp.json and remove finalizers kubernetes
kubectl proxy (in separate tab)
curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:8001/api/v1/namespaces/monitoring/finalize
kubectl get namespaces

# aws eks node logs
kubectl exec -it aws-node-9cwkd -n kube-system -- /bin/bash cat /host/var/log/aws-routed-eni/ipamd.log

# Update main Kubernetes manifests and PODs
# updating config files, example:
sudo nano /etc/kubernetes/scheduler.conf # here there are many config files critical to k8s
# then on master nodes you can edit the live manifests:
sudo nano /etc/kubernetes/manifests/kube-apiserver.yaml # updates in Kubernetes are done in 3-4 seconds
sudo nano /etc/kubernetes/manifests/kube-controller-manager.yaml
sudo rm /etc/kubernetes/*.old && sudo rm /etc/kubernetes/*~

# Certificates expired: x509: certificate has expired or is not yet valid
kubeadm certs check-expiration
kubeadm certs renew all
systemctl restart kubelet
# now go to /etc/kubernetes and copy the client-certificate-data and client-key-data values from the file admin.conf

# Work with apiservices
kubectl get apiservice --all-namespaces
kubectl get apiservice v1beta1.external.metrics.k8s.io -o yaml
kubectl describe apiservice v1beta1.metrics.k8s.io -n kube-system
kubectl edit apiservice v1beta1.metrics.k8s.io -n kube-system
kubectl get --raw='/readyz?verbose' # test api services

# Debug container with busybox
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh

# Check metrics reporting for a node
kubectl get --raw /api/v1/nodes/NODE_NAME/proxy/metrics/resource

# Metrics server certificates error from k8s api service
# Reference: https://github.com/kubernetes-sigs/metrics-server/issues/576
kubectl get cm -n kube-system extension-apiserver-authentication -o json | jq -r ".data[\"client-ca-file\"]" | openssl x509 > ../client-ca.pem
openssl verify -verbose -CAfile client-ca.pem  master-4-cluster1682686205-chain.pem
verification failed
kubectl edit cm -n kube-system kubelet-config # set serverTLSBootstrap: true so kubelet is providing certificates
sudo kubeadm upgrade node phase kubelet-config # on each node
sudo systemctl restart kubelet.service # on each node
kubectl get csr -n kube-system # get certificates requests
kubectl certificate approve ... # approve certificates

# Cilium related
k annotate gateway gw-name  cert-manager.io/cluster-issuer=letsencrypt-cluster-issuer -n namespace
k describe Gateway gw-name -n namespace