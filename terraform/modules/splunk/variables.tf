variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace where Splunk collector will be deployed"
  type        = string
  default     = "splunk"
}

variable "splunk_hec_endpoint" {
  description = "Splunk HEC endpoint URL used for log ingestion"
  type        = string
}

variable "splunk_hec_token" {
  description = "Authentication token for Splunk HEC"
  type        = string
  sensitive   = true
}

variable "splunk_index" {
  description = "Splunk index where logs will be stored"
  type        = string
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster"
  type        = string
}
