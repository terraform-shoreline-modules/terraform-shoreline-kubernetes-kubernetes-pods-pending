#!/bin/bash

# Set parameters

NAMESPACE=${NAMESPACE}

POD_NAME=${POD_NAME}

RESOURCE=${RESOURCE_TYPE}

RESOURCE_LIMIT=${RESOURCE_LIMIT}

# Check current resource allocation

CURRENT_LIMIT=$(kubectl get pod $POD_NAME -n $NAMESPACE -o=jsonpath="{.spec.containers[0].resources.limits.$RESOURCE}")

echo "Current $RESOURCE limit for $POD_NAME is $CURRENT_LIMIT"

# Increase resource allocation if necessary

if [ "$CURRENT_LIMIT" -lt "$RESOURCE_LIMIT" ]; then

    kubectl patch pod $POD_NAME -n $NAMESPACE --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/resources/limits/'$RESOURCE'", "value": "'$RESOURCE_LIMIT'"}]'

    echo "Increased $RESOURCE limit for $POD_NAME to $RESOURCE_LIMIT"

else

    echo "Current $RESOURCE limit for $POD_NAME is already greater than or equal to $RESOURCE_LIMIT"

fi