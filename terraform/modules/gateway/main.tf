# Install NGINX Gateway Fabric controller
resource "helm_release" "nginx_gateway" {
  name             = "nginx-gateway"
  repository       = "https://helm.nginx.com/stable"
  chart            = "nginx-gateway-fabric"
  namespace        = "nginx-gateway"
  create_namespace = true

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

        # Temporary: disable TLS so controller listens on HTTP
        tls = {
          enable = false
        }
      }

      nginx = {
        image = {
          repository = var.nginx_image_repository
          tag        = var.nginx_image_tag
        }
      }
    })
  ]
}
