provider "kubernetes" {}

locals {
  app = "nginx"
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = local.app

  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = local.app
      }
    }

    template {
      metadata {
        labels = {
          app = local.app
        }
      }

      spec {
        container {
          name = "nginx"

          image = "nginx:${var.tag}"

          // example what happens when you don't use dynamic and loops

          port {
            container_port = 80
            name = "first"
          }

          port {
            container_port = 8080
            name = "second"
          }

          port {
            container_port = 8081
            name = "third"
          }

          port {
            container_port = 8082
            name = "fourth"
          }

          dynamic "volume_mount" {
            for_each = local.files_map

            content {
              name = md5(volume_mount.key)
              mount_path = "/etc/nginx/conf.d/${volume_mount.key}"
              sub_path = volume_mount.key 
            }  
          }
        }

        dynamic "volume" {
          for_each = local.files_map

          content {
            name = md5(volume.key)

            config_map {
              name = kubernetes_config_map.nginx[volume.key].metadata.0.name

              items {
                key = volume.key
                path = volume.key
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = local.app

    annotations = {
      "cloud.google.com/neg" = jsonencode({
        ingress = true
      })
    }
  }

  spec {
    type = "LoadBalancer"

    port {
      port = 80
      target_port = 80
      name = "first"
    }

    port {
      port = 8080
      target_port = 8080
      name = "second"
    }

    port {
      port = 8081
      target_port = 8081
      name = "third"
    }

    port {
      port = 8082
      target_port = 8082
      name = "fourth"
    }

    selector = {
      app = kubernetes_deployment.nginx.metadata.0.name
    }
  }
}