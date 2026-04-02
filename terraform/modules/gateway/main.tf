# Install Gateway API CRDs
resource "null_resource" "gateway_api_crds" {
  triggers = {
    version = "v1.5.0"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml"
  }
}

# Install NGINX Gateway Fabric controller
resource "helm_release" "nginx_gateway" {
  name             = "nginx-gateway"
  repository       = "oci://ghcr.io/nginxinc/charts"
  chart            = "nginx-gateway-fabric"
  namespace        = "nginx-gateway"
  create_namespace = true

  depends_on = [null_resource.gateway_api_crds]

  values = [
    yamlencode({
      service = {
        type = "LoadBalancer"
      }

      nginxGateway = {
        image = {
          repository = var.gateway_image_repository
          tag        = var.gateway_image_tag
        }
      }
    })
  ]
}
