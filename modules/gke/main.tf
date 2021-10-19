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

data "google_client_config" "default" {}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.gke_subnet
  region  = var.region
  project = var.project_id
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "17.0.0"

  project_id      = var.project_id
  name            = var.cluster_name
  release_channel = "REGULAR"

  regional                 = true
  region                   = var.region
  network                  = var.gke_network
  subnetwork               = var.gke_subnet
  ip_range_pods            = var.ip_range_pods
  ip_range_services        = var.ip_range_services
  datapath_provider        = "ADVANCED_DATAPATH"
  enable_l4_ilb_subsetting = var.enable_l4_ilb_subsetting

  default_max_pods_per_node = var.max_pods_per_node

  enable_private_endpoint      = false
  enable_private_nodes         = true
  remove_default_node_pool     = true
  master_global_access_enabled = true

  cluster_telemetry_type = "ENABLED"
  # monitoring_config            = ["SYSTEM_COMPONENTS" /*, "WORKLOADS"*/]

  gce_pd_csi_driver = true

  maintenance_recurrence = var.maintenance_recurrence
  maintenance_start_time = var.maintenance_start_time

  cluster_resource_labels      = var.cluster_resource_labels
  authenticator_security_group = var.authenticator_security_group
  node_metadata                = "GKE_METADATA_SERVER"
  enable_binary_authorization  = var.enable_binary_authorization
  master_ipv4_cidr_block       = var.ip_range_controlplane
  node_pools = [
    {
      name              = var.node_pool_name
      min_count         = var.min_nodes
      max_count         = var.max_nodes
      local_ssd_count   = 0
      disk_size_gb      = var.disk_size_gb
      disk_type         = var.disk_type
      machine_type      = var.machine_type
      image_type        = "COS"
      auto_repair       = true
      auto_upgrade      = true
      preemptible       = false
      max_pods_per_node = var.max_pods_per_node
    },
  ]

  node_pools_tags = var.node_pools_tags
}

# Cluster authentication
module "gke-auth" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version = "~> 17.0.0"

  project_id   = var.project_id
  cluster_name = module.gke.name
  location     = module.gke.region

  use_private_endpoint = false
}
