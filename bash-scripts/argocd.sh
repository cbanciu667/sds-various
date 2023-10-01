#!/bin/bash

# https://argo-cd.readthedocs.io/en/stable/user-guide/

# on physical servers, instead of NGINX ingress use Metalb LoudBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# edit the argocd deployment and use the latest argocd image: argoproj/argocd:latest
KUBE_EDITOR="nano" kubectl -n argocd edit deployment  argocd-server

# configure git secret 
cat ~/.ssh/sds-kubernetes-argocd | base64
kubectl apply -f git-secret.yaml
kubectl apply -f git-secrets-to-git-repos.yaml

# ArgoCD Image updater
# HELM charts: https://artifacthub.io/packages/helm/argo/argocd-image-updater
kubectl --namespace argocd logs --selector app.kubernetes.io/name=argocd-image-updater --follow
# install cli
wget https://github.com/argoproj-labs/argocd-image-updater/releases/download/v0.12.0/argocd-image-updater-darwin_arm64 -O /usr/local/bin/argocd-image-updater
chmod 755 /usr/local/bin/argocd-image-updater
argocd-image-updater version
# remote testing
argocd-image-updater test nginx --platforms darwin/arm64
# local testing
argocd-image-updater test 800800800800.dkr.ecr.eu-central-1.amazonaws.com/nginx-example \
    --platforms linux/arm64 \
    --registries-conf-path ./reg.conf \
    --update-strategy latest

# argocd cli commands examples
argocd login ARGOCD_DOMAIN --username admin --password PASSWROD
argocd cluster add
argocd proj get PROJ_NAME
argocd proj list
argocd app get AP_NAME
argo app delete APP --cascade
argocd repocreds list
argocd app sync AP_NAME
argocd app sync -l app.kubernetes.io/instance=apps
argocd app logs prometheus --follow --tail 10 --namespace monitoring

# Fix for app stuck in deletion
kubectl patch app redis -n prod --type json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'

# Fix for issue with istio webhook-validator:
# In the istio-base app add ignoreDifferencesStatement
# https://github.com/argoproj/argo-cd/issues/9323

# Fix Prometheus CRD apply failure due "too long error":
# https://github.com/prometheus-community/helm-charts/issues/1500
# or apply all the CRDs as specified here:
# https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
# and after that UPGRADE to newer version of the helm chart
