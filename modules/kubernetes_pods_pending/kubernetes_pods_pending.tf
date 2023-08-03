resource "shoreline_notebook" "kubernetes_pods_pending" {
  name       = "kubernetes_pods_pending"
  data       = file("${path.module}/data/kubernetes_pods_pending.json")
  depends_on = [shoreline_action.invoke_resource_checker,shoreline_action.invoke_pod_status_check,shoreline_action.invoke_resource_limit_changer]
}

resource "shoreline_file" "resource_checker" {
  name             = "resource_checker"
  input_file       = "${path.module}/data/resource_checker.sh"
  md5              = filemd5("${path.module}/data/resource_checker.sh")
  description      = "Insufficient resources allocated to the Kubernetes cluster, such as CPU, memory, or storage."
  destination_path = "/agent/scripts/resource_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "pod_status_check" {
  name             = "pod_status_check"
  input_file       = "${path.module}/data/pod_status_check.sh"
  md5              = filemd5("${path.module}/data/pod_status_check.sh")
  description      = "Misconfiguration of the pod specifications, such as incorrect image names or container ports, preventing the pods from starting."
  destination_path = "/agent/scripts/pod_status_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "resource_limit_changer" {
  name             = "resource_limit_changer"
  input_file       = "${path.module}/data/resource_limit_changer.sh"
  md5              = filemd5("${path.module}/data/resource_limit_changer.sh")
  description      = "Check the resource allocation for the pods to ensure that they have sufficient resources to run. Increase the resource allocation if necessary."
  destination_path = "/agent/scripts/resource_limit_changer.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_resource_checker" {
  name        = "invoke_resource_checker"
  description = "Insufficient resources allocated to the Kubernetes cluster, such as CPU, memory, or storage."
  command     = "`chmod +x /agent/scripts/resource_checker.sh && /agent/scripts/resource_checker.sh`"
  params      = ["POD_NAME","RESOURCE_TYPE","NAMESPACE"]
  file_deps   = ["resource_checker"]
  enabled     = true
  depends_on  = [shoreline_file.resource_checker]
}

resource "shoreline_action" "invoke_pod_status_check" {
  name        = "invoke_pod_status_check"
  description = "Misconfiguration of the pod specifications, such as incorrect image names or container ports, preventing the pods from starting."
  command     = "`chmod +x /agent/scripts/pod_status_check.sh && /agent/scripts/pod_status_check.sh`"
  params      = ["POD_NAME","CONTAINER_NAME","NAMESPACE"]
  file_deps   = ["pod_status_check"]
  enabled     = true
  depends_on  = [shoreline_file.pod_status_check]
}

resource "shoreline_action" "invoke_resource_limit_changer" {
  name        = "invoke_resource_limit_changer"
  description = "Check the resource allocation for the pods to ensure that they have sufficient resources to run. Increase the resource allocation if necessary."
  command     = "`chmod +x /agent/scripts/resource_limit_changer.sh && /agent/scripts/resource_limit_changer.sh`"
  params      = ["POD_NAME","RESOURCE_TYPE","NAMESPACE","RESOURCE_LIMIT"]
  file_deps   = ["resource_limit_changer"]
  enabled     = true
  depends_on  = [shoreline_file.resource_limit_changer]
}

