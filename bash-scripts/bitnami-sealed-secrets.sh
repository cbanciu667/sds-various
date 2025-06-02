#!/bin/bash

# https://github.com/bitnami-labs/sealed-secrets/tree/main/helm/sealed-secrets

# deploy with argocd cli
kubectl create namespace bitnami-secrets
argocd app create sealed-secrets --repo https://bitnami-labs.github.io/sealed-secrets \
  --helm-chart sealed-secrets/sealed-secrets --revision REVISION \
  --dest-namespace bitnami-secrets  \
  --dest-server https://kubernetes.default.svc

# get the pub key
kubeseal --fetch-cert \
  --controller-name=kube-system \
  --controller-namespace=bitnami-secrets > bitnami-pub-key/bitnami-pub.pem

# seal and apply secrets
kubeseal --format=yaml --cert=bitnami-pub-key/bitnami-pub.pem < argo-system/git-secret.yaml > argo-system/sealed-git-secret.yaml
kubeseal --format=yaml --cert=bitnami-pub-key/bitnami-pub.pem < argo-system/argo-aws-secret.yaml > argo-system/sealed-argo-aws-secret.yaml
kubeseal \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=kube-system \
  --fetch-cert > bitnami-pub-key/bitnami-pub.pem
kubectl create secret generic cluster-issuer-secret --dry-run=client -n cert-manager \
  --from-literal=secret-access-key=mXIDGIUFDGUFGDIDUFG -o yaml | \
  kubeseal \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=kube-system \
  --cert bitnami-pub-key/bitnami-pub.pem \
  --scope strict \
  --format yaml > cluster-init/sealed-cluster-issuer-r53-secret.yaml
kubectl create secret generic --dry-run -output json \
mysecret  --from-literal=password=supersekret | kubeseal > mysealedsecret.json
kubectl apply -f argo-system/sealed-git-secret.yaml
kubectl apply -f argo-system/sealed-argo-aws-secret.yaml
kubectl create -f mysealedsecret.json
kubectl get secret mysecret
