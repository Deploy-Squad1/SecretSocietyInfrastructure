resource "helm_release" "splunk_otel" {
  name       = "splunk-otel-${var.environment}"
  repository = "https://signalfx.github.io/splunk-otel-collector-chart"
  chart      = "splunk-otel-collector"
  namespace  = var.namespace

  create_namespace = true

  values = [
    yamlencode({
      splunkPlatform = {
        endpoint           = var.splunk_hec_endpoint
        token              = var.splunk_hec_token
        index              = var.splunk_index
        insecureSkipVerify = true
      }

      clusterName = var.cluster_name
    })
  ]
}
