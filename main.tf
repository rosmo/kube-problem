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

provider "google" {
}

provider "google-beta" {
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.88.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.88.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.0"
    }
  }
}

# Activate necessary APIs and retrieve project details
module "project" {
  source = "./modules/project"

  project_id = var.project_id
}

# Create the VPC network
module "network" {
  source = "./modules/network"

  project_id = var.project_id
  region     = var.region
  network    = var.network

  cidr_range          = var.cidr_range
  cidr_range_pods     = var.cidr_range_pods
  cidr_range_services = var.cidr_range_services

  depends_on = [
    module.project
  ]
}

# Create regional GKE cluster
module "gke" {
  source     = "./modules/gke"
  project_id = var.project_id
  region     = var.region

  cluster_name = "haven-compliance-cluster"

  gke_network              = module.network.network_name
  gke_subnet               = module.network.gke_subnet.name
  ip_range_pods            = module.network.gke_pod_subnet
  ip_range_services        = module.network.gke_services_subnet
  ip_range_controlplane    = var.cidr_range_controlplane
  enable_l4_ilb_subsetting = true

  machine_type      = var.cluster_instance_type
  max_pods_per_node = 64
  max_nodes         = 4
  min_nodes         = 1
  node_pool_name    = "gke-nodepool"

  disk_size_gb = 100
  disk_type    = "pd-balanced"

  maintenance_recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
  maintenance_start_time = "03:00"
  node_pools_tags = {
    all = [
      var.project_id
    ]
  }
  cluster_resource_labels = {
    project = var.project_id
  }
  authenticator_security_group = null
  enable_binary_authorization  = false
}

provider "kubernetes" {
  cluster_ca_certificate = module.gke.auth.cluster_ca_certificate
  host                   = module.gke.auth.host
  token                  = module.gke.auth.token

  experiments {
    manifest_resource = true
  }
}

provider "helm" {
  kubernetes {
    cluster_ca_certificate = module.gke.auth.cluster_ca_certificate
    host                   = module.gke.auth.host
    token                  = module.gke.auth.token
  }
}

# Example deployment of Nginx that uses a shared NFS volume to serve docroot
module "example-deployment" {
  source = "./modules/example-deployment"

  depends_on = [
    module.gke,
  ]
}
