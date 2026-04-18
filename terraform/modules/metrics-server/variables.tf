variable "namespace" {
  description = "Namespace where metrics-server will be deployed"
  type        = string
}

variable "helm_release_name" {
  description = "Helm release name for metrics-server"
  type        = string
}
