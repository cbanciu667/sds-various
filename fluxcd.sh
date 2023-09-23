#!/bin/bash

# https://fluxcd.io/flux/

# bootstrap example
flux bootstrap git \
  --context=arn:aws:eks:eu-central-1:1381003681000:cluster/cluster-dev \
  --components-extra=image-reflector-controller,image-automation-controller \
  --url=ssh://git@bitbucket.org/mygitorg/gitops-dev.git \
  --branch=master \
  --path=clusters/cluster-dev \
  --private-key-file=/Users/myuser/.ssh/fluxcd_ssh_key \
  --interval=1m \
  --version=v2.0.1 \
  --verbose

# init private git repository
flux create secret git flux-system \
  --url=ssh://git@bitbucket.org/mygitorg/gitops.git \
  --namespace flux-system \
  --private-key-file=/Users/myuser/.ssh/fluxcd_ssh_key \
  --password=SecretPassword
flux create source git sops-gpg \
  --url=ssh://git@bitbucket.org/mygitorg/gitops.git \
  --branch=master \
  --private-key-file=/Users/myuser/.ssh/fluxcd_ssh_key


# fluxcd cli commands examples
flux check
flux reconcile source git flux-system
flux reconcile kustomization test-kustomization --with-source
flux reconcile helmrelease fluentd fluentd --with-source -n monitoring
flux get images all --all-namespaces
flux suspend helmrelease fluentd fluentd -n monitoring
flux resume helmrelease fluentd fluentd -n monitoring
flux suspend kustomization apps
flux resume kustomization apps

# install specific fluxcd cli version
curl -s https://fluxcd.io/install.sh | sudo FLUX_VERSION=0.41.2 bash

# notifications with MS teams
kubectl -n flux-system create secret generic teams-url \
--from-literal=address=https://webaddress.webhook.office.com/webhookb2/webhook_id/IncomingWebhook/4webhook_id4

# disable prunning garbage collection 
# example:
# apiVersion: v1
# kind: Namespace
# metadata:
#   name: kube-system
#   annotations:
#     fluxcd.io/ignore: sync_only
#     kustomize.toolkit.fluxcd.io/prune: disabled

# Fix for prometheus-node-exporter error: 
#
# Helm upgrade failed: unable to build kubernetes objects from current release manifest:
# resource mapping not found for name: "prometheus-node-exporter" namespace: "monitoring" from "": no matches for kind "PodSecurityPolicy" in version "policy/v1beta1"
#
helm plugin install https://github.com/helm/helm-mapkubeapis
helm mapkubeapis prometheus-node-exporter -n monitoring
flux suspend  helmrelease prometheus-node-exporter -n monitoring
flux resume helmrelease prometheus-node-exporter -n monitoring
