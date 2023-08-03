#!/bin/bash

# Replace ${POD_NAME} and ${NAMESPACE} with the actual values

POD_NAME="${POD_NAME}"

NAMESPACE="${NAMESPACE}"

# Get the pod description and check the status

POD_DESC=$(kubectl describe pod $POD_NAME -n $NAMESPACE)

STATUS=$(echo "$POD_DESC" | awk '/Status:/{print $2}')

if [[ "$STATUS" == "Error" ]]; then

  # Check the container status and logs

  CONTAINER_STATUS=$(echo "$POD_DESC" | awk '/Container Status:/{print $3}')

  if [[ "$CONTAINER_STATUS" == "Error" ]]; then

    CONTAINER_NAME=$(echo "$POD_DESC" | awk '/Container ID:/{print $3}' | cut -d '/' -f 3)

    CONTAINER_LOGS=$(kubectl logs $POD_NAME -c $CONTAINER_NAME -n $NAMESPACE)

    echo "Container logs: $CONTAINER_LOGS"

  else

    echo "Container status: $CONTAINER_STATUS"

  fi

else

  echo "Pod status: $STATUS"

fi