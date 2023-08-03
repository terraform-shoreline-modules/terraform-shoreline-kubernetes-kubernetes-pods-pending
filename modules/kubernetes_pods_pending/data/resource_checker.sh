#!/bin/bash

# Set variables

NAMESPACE=${NAMESPACE}

POD_NAME=${POD_NAME}

RESOURCE=${RESOURCE_TYPE} # e.g. cpu, memory, storage

# Get the resource limits and requests for the pod

LIMIT=$(kubectl describe pod $POD_NAME -n $NAMESPACE | grep "Limits" | awk '{print $2}')

REQUEST=$(kubectl describe pod $POD_NAME -n $NAMESPACE | grep "Requests" | awk '{print $2}')

# Remove the unit from the limit and request values

LIMIT=${LIMIT//Mi/}

LIMIT=${LIMIT//Gi/}

REQUEST=${REQUEST//Mi/}

REQUEST=${REQUEST//Gi/}

# Convert the limit and request values to integers

LIMIT=$(echo $LIMIT | awk '{print int($1)}')

REQUEST=$(echo $REQUEST | awk '{print int($1)}')

# Get the usage of the resource for the pod

USAGE=$(kubectl top pod $POD_NAME -n $NAMESPACE | awk '{print $3}')

USAGE=${USAGE//Mi/}

USAGE=${USAGE//Gi/}

USAGE=$(echo $USAGE | awk '{print int($1)}')

# Calculate the available resource for the pod

AVAILABLE=$((LIMIT - USAGE))

# Check if the available resource is less than the requested resource

if [ $AVAILABLE -lt $REQUEST ]; then

    echo "Insufficient $RESOURCE allocated to the Kubernetes cluster for pod $POD_NAME"

    echo "Limit: $LIMIT$RESOURCE, Request: $REQUEST$RESOURCE, Usage: $USAGE$RESOURCE, Available: $AVAILABLE$RESOURCE"

else

    echo "Sufficient $RESOURCE allocated to the Kubernetes cluster for pod $POD_NAME"

    echo "Limit: $LIMIT$RESOURCE, Request: $REQUEST$RESOURCE, Usage: $USAGE$RESOURCE, Available: $AVAILABLE$RESOURCE"

fi