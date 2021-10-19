#   Copyright 2021 Google LLC
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.5.0"
    }
  }
}

# Add namespace for running Nginx
resource "kubernetes_namespace" "nginx-namespace" {
  metadata {
    name = var.namespace
  }
}

# Add Nginx "Hello World" deployment
resource "kubernetes_deployment" "nginx-test" {
  metadata {
    name      = var.deployment_name
    namespace = kubernetes_namespace.nginx-namespace.metadata.0.name
    labels = {
      app = "example"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "example"
      }
    }

    template {
      metadata {
        labels = {
          app = "example"
        }
        annotations = {
          # This is deprecated, but Terraform doesn't support seccomp field yet
          "seccomp.security.alpha.kubernetes.io/pod" = "runtime/default"
        }
      }

      spec {
        automount_service_account_token = false
        security_context {
          run_as_group    = 101
          run_as_user     = 101
          run_as_non_root = true
        }
        container {
          image = var.nginx_container
          name  = "nginx-test"

          port {
            container_port = 8080
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            run_as_non_root            = true
            capabilities {
              drop = ["NET_RAW"]
            }
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
