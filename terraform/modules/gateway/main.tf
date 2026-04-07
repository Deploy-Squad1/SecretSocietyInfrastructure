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
    })
  ]
}

# Gateway resource
resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "nginx-gateway"
      namespace = var.app_namespace
    }
    spec = {
      gatewayClassName = "nginx"
      listeners = [
        {
          name     = "http"
          port     = 80
          protocol = "HTTP"

          hostname = var.gateway_hostname

          allowedRoutes = {
            namespaces = {
              from = "Same"
            }
          }
        },
        {
          name     = "https"
          port     = 443
          protocol = "HTTPS"

          tls = {
            mode = "Terminate"
            certificateRefs = [
              {
                kind = "Secret"
                name = "app-tls"
              }
            ]
          }

          allowedRoutes = {
            namespaces = {
              from = "Same"
            }
          }
        }
      ]
    }
  }

  depends_on = [helm_release.nginx_gateway]

  field_manager {
    force_conflicts = true
  }
}
