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

variable "splunk_observability_realm" {
  description = "Splunk Observability Cloud realm used for metrics ingestion"
  type        = string
}

variable "splunk_observability_access_token" {
  description = "Accesss token for Splunk obserability Cloud used by the collector to send metrics"
  type        = string
  sensitive   = true
}
