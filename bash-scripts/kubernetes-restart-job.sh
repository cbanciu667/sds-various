#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <job_name> <namespace>"
  exit 1
fi

job_name="$1"
namespace="$2"

kubectl get job ${job_name} -n ${namespace} -o yaml | yq eval 'del(.spec.selector)' - | yq eval 'del(.spec.template.metadata.labels."controller-uid")' - | yq eval 'del(.metadata.creationTimestamp)' - | yq eval 'del(.metadata.selfLink)' - | yq eval 'del(.metadata.uid)' - | yq eval 'del(.metadata.resourceVersion)' - | yq eval 'del(.metadata.managedFields)' - | yq eval 'del(.status)' - > job.yaml

kubectl delete job ${job_name} -n ${namespace}
kubectl create -f job.yaml -n ${namespace}

# Optional: Remove the job.yaml file after recreation
rm job.yaml
