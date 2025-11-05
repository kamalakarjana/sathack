#!/bin/bash

echo "=== Testing Application Endpoints Directly ==="

# Test patient service endpoints
echo "Patient Service Endpoints:"
kubectl port-forward -n lbg-ns service/patient-service 8080:3000 > /dev/null 2>&1 &
PATIENT_PID=$!
sleep 5

echo "Testing /health:"
curl -v http://localhost:8080/health
echo ""
echo "Testing /patients:"
curl -v http://localhost:8080/patients
echo ""
echo "Testing /:"
curl -v http://localhost:8080/
echo ""

kill $PATIENT_PID 2>/dev/null

# Test appointment service endpoints
echo "Appointment Service Endpoints:"
kubectl port-forward -n lbg-ns service/appointment-service 8081:3001 > /dev/null 2>&1 &
APPOINTMENT_PID=$!
sleep 5

echo "Testing /health:"
curl -v http://localhost:8081/health
echo ""
echo "Testing /appointments:"
curl -v http://localhost:8081/appointments
echo ""
echo "Testing /:"
curl -v http://localhost:8081/
echo ""

kill $APPOINTMENT_PID 2>/dev/null
