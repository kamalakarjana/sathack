#!/bin/bash
echo "=== COMPREHENSIVE DEPLOYMENT TEST ==="

# Get AKS credentials
az aks get-credentials --resource-group kamalakar-demo-dev --name kamal-lgb-aks-cluster-dev --overwrite-existing

echo "1. Checking all resources..."
kubectl get all -n lbg-ns

echo ""
echo "2. Checking ingress details..."
kubectl describe ingress lbg-app-ingress -n lbg-ns

echo ""
echo "3. Testing services via port-forward..."
echo "Testing Patient Service:"
kubectl port-forward -n lbg-ns service/patient-service 8080:3000 > /dev/null 2>&1 &
PATIENT_PID=$!
sleep 3
curl -s http://localhost:8080/health && echo "✅ Patient Service: HEALTHY" || echo "❌ Patient Service: UNHEALTHY"
kill $PATIENT_PID 2>/dev/null

echo "Testing Appointment Service:"
kubectl port-forward -n lbg-ns service/appointment-service 8081:3001 > /dev/null 2>&1 &
APPOINTMENT_PID=$!
sleep 3
curl -s http://localhost:8081/health && echo "✅ Appointment Service: HEALTHY" || echo "❌ Appointment Service: UNHEALTHY"
kill $APPOINTMENT_PID 2>/dev/null

echo ""
echo "4. Testing via ingress..."
EXTERNAL_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -n "$EXTERNAL_IP" ]; then
  echo "External IP: $EXTERNAL_IP"
  
  echo "Testing endpoints:"
  echo "- /health: $(curl -s -o /dev/null -w "%{http_code}" -H "Host: lbg-app.dev.local" http://$EXTERNAL_IP/health)"
  echo "- /patients: $(curl -s -o /dev/null -w "%{http_code}" -H "Host: lbg-app.dev.local" http://$EXTERNAL_IP/patients)"
  echo "- /appointments: $(curl -s -o /dev/null -w "%{http_code}" -H "Host: lbg-app.dev.local" http://$EXTERNAL_IP/appointments)"
else
  echo "❌ No external IP found"
fi

echo ""
echo "=== TEST COMPLETED ==="
