#!/bin/bash

# Namespaces to target
namespaces=("staging" "uat" "prod")

# Get all contexts from kubeconfig
contexts=$(kubectl config get-contexts -o name)

for context in $contexts; do
  echo "🔄 Switching to context: $context"
  kubectl config use-context "$context" >/dev/null 2>&1

  for ns in "${namespaces[@]}"; do
    # Check if namespace exists
    if kubectl get ns "$ns" >/dev/null 2>&1; then
      echo "🔁 Restarting deployment 'airflow-web' in namespace '$ns' for context '$context'"
      kubectl rollout restart deployment airflow-web -n "$ns"
    else
      echo "❌ Namespace '$ns' not found in context '$context'"
    fi
  done
done

