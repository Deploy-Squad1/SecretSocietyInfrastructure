resource "helm_release" "splunk_otel" {
  name       = "splunk-otel-${var.environment}"
  repository = "https://signalfx.github.io/splunk-otel-collector-chart"
  chart      = "splunk-otel-collector"
  namespace  = var.namespace

  create_namespace = true

  values = [
    yamlencode({
      clusterName = var.cluster_name

      splunkPlatform = {
        endpoint           = var.splunk_hec_endpoint
        token              = var.splunk_hec_token
        index              = var.splunk_index
        insecureSkipVerify = true
      }

      splunkObservability = {
        realm       = var.splunk_observability_realm
        accessToken = var.splunk_observability_access_token
      }
    })
  ]
}
