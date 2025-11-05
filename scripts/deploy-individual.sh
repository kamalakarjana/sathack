#!/bin/bash
set -e

echo "=== Individual Resource Deployment ==="
cd /home/ec2-user/lbg-qwert/kubernetes/helm

COMMIT_SHA=$1
ACR_LOGIN_SERVER=$2

if [ -z "$COMMIT_SHA" ] || [ -z "$ACR_LOGIN_SERVER" ]; then
  echo "Usage: $0 <commit-sha> <acr-login-server>"
  exit 1
fi

echo "Using commit: $COMMIT_SHA"
echo "Using ACR: $ACR_LOGIN_SERVER"

# Create namespace if not exists
kubectl create namespace lbg-ns --dry-run=client -o yaml | kubectl apply -f -

# Create ACR secret
kubectl create secret docker-registry acr-secret \
  --namespace lbg-ns \
  --docker-server=$ACR_LOGIN_SERVER \
  --docker-username=$AZURE_CLIENT_ID \
  --docker-password=$AZURE_CLIENT_SECRET \
  --dry-run=client -o yaml | kubectl apply -f -

# Step 1: Deploy ConfigMap
echo "=== Deploying ConfigMap ==="
helm template lbg-app . \
  --namespace lbg-ns \
  -f values-dev.yml \
  --set patientService.tag=$COMMIT_SHA \
  --set appointmentService.tag=$COMMIT_SHA \
  --set image.registry=$ACR_LOGIN_SERVER \
  --show-only templates/configMap.yaml | kubectl apply -f -

# Step 2: Deploy Services
echo "=== Deploying Services ==="
helm template lbg-app . \
  --namespace lbg-ns \
  -f values-dev.yml \
  --show-only templates/patient-service/service.yaml | kubectl apply -f -

helm template lbg-app . \
  --namespace lbg-ns \
  -f values-dev.yml \
  --show-only templates/appointment-service/service.yaml | kubectl apply -f -

# Step 3: Deploy Deployments
echo "=== Deploying Deployments ==="
helm template lbg-app . \
  --namespace lbg-ns \
  -f values-dev.yml \
  --set patientService.tag=$COMMIT_SHA \
  --set appointmentService.tag=$COMMIT_SHA \
  --set image.registry=$ACR_LOGIN_SERVER \
  --show-only templates/patient-service/deployment.yaml | kubectl apply -f -

helm template lbg-app . \
  --namespace lbg-ns \
  -f values-dev.yml \
  --set patientService.tag=$COMMIT_SHA \
  --set appointmentService.tag=$COMMIT_SHA \
  --set image.registry=$ACR_LOGIN_SERVER \
  --show-only templates/appointment-service/deployment.yaml | kubectl apply -f -

# Step 4: Deploy HPA
echo "=== Deploying HPA ==="
helm template lbg-app . \
  --namespace lbg-ns \
  -f values-dev.yml \
  --show-only templates/patient-service/hpa.yaml | kubectl apply -f -

helm template lbg-app . \
  --namespace lbg-ns \
  -f values-dev.yml \
  --show-only templates/appointment-service/hpa.yaml | kubectl apply -f -

# Step 5: Deploy Ingress
echo "=== Deploying Ingress ==="
helm template lbg-app . \
  --namespace lbg-ns \
  -f values-dev.yml \
  --show-only templates/ingress.yaml | kubectl apply -f -

echo "=== All resources deployed successfully ==="

# Wait for deployments
echo "=== Waiting for deployments to be ready ==="
kubectl wait --for=condition=available deployment/patient-service -n lbg-ns --timeout=300s
kubectl wait --for=condition=available deployment/appointment-service -n lbg-ns --timeout=300s

echo "=== Deployment completed successfully ==="
