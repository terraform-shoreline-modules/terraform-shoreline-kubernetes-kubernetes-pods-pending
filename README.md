
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes Pods Pending
---

Kubernetes Pods Pending incident indicates that one or more pods in a Kubernetes cluster are not running as expected and are in a pending state. This can happen due to various reasons such as resource constraints, scheduling issues, or network problems. This incident can impact the availability and performance of the application running on the Kubernetes cluster. It requires immediate attention to diagnose and resolve the underlying issue to ensure the pods are running as expected.

### Parameters
```shell
# Environment Variables

export NAMESPACE="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"

export RESOURCE_TYPE="PLACEHOLDER"

export RESOURCE_LIMIT="PLACEHOLDER"
```

## Debug

### Get the list of namespaces in the Kubernetes cluster
```shell
kubectl get namespaces
```

### Get the list of pods in a specific namespace
```shell
kubectl get pods -n ${NAMESPACE}
```

### Get the details of a specific pod
```shell
kubectl describe pod ${POD_NAME} -n ${NAMESPACE}
```

### Get the list of events related to a specific pod
```shell
kubectl get events -n ${NAMESPACE} --field-selector involvedObject.name=${POD_NAME}
```

### Check the pod's YAML configuration file for any issues
```shell
kubectl get pod ${POD_NAME} -n ${NAMESPACE} -o yaml
```
### Check the status of the nodes in the Kubernetes cluster
```shell
kubectl get nodes
```

### Check the resource usage of the nodes in the Kubernetes cluster
```shell
kubectl top nodes
```

### Insufficient resources allocated to the Kubernetes cluster, such as CPU, memory, or storage.
```shell
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


```

### Misconfiguration of the pod specifications, such as incorrect image names or container ports, preventing the pods from starting.
```shell
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

```

## Repair

### Check the resource allocation for the pods to ensure that they have sufficient resources to run. Increase the resource allocation if necessary.
```shell
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

```