# Install Gateway API CRDs
resource "null_resource" "gateway_api_crds" {
  provisioner "local-exec" {
    command = <<EOT
kubectl apply -f ${path.module}/files/standard-install.yaml
EOT
  }
}

# Install NGINX Gateway Fabric controller
resource "helm_release" "nginx_gateway" {
  name             = "nginx-gateway"
  chart            = "${path.module}/nginx-gateway-fabric"
  namespace        = "nginx-gateway"
  create_namespace = true

  recreate_pods = true

  depends_on = [
    null_resource.gateway_api_crds
  ]

  values = [
    yamlencode({
      nginxGateway = {
        image = {
          repository = var.image_repository
          tag        = var.image_tag
        }

        # Temporary: disable TLS so controller listens on HTTP
        tls = {
          enable = false
        }
      }
    })
  ]
}
