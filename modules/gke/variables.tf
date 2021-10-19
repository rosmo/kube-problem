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

variable "authenticator_security_group" {
  description = "The name of the RBAC security group for use with Google security groups in Kubernetes RBAC. Group name must be in format gke-security-groups@yourdomain.com"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster to be created"
  type        = string
}

variable "cluster_resource_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  type        = map(string)
}

variable "disk_size_gb" {
  description = "Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB."
  type        = number
}

variable "disk_type" {
  description = "Type of the disk attached to each node (e.g. 'pd-standard' or 'pd-ssd')"
  type        = string
}

variable "ip_range_pods" {
  description = "The name of the secondary subnet ip range to use for pods"
  type        = string
}

variable "ip_range_services" {
  description = "The name of the secondary subnet range to use for services"
  type        = string
}

variable "ip_range_controlplane" {
  description = "Control plane IP range"
  type        = string
}

variable "gke_network" {
  description = "The VPC network to host the cluster in"
  type        = string
}

variable "gke_subnet" {
  description = "The subnetwork to host the cluster in"
  type        = string
}

variable "machine_type" {
  description = "The name of a Google Compute Engine machine type"
  type        = string
}

variable "maintenance_recurrence" {
  description = "Frequency of the recurring maintenance window in RFC5545 format"
  type        = string
}

variable "maintenance_start_time" {
  description = "Time window specified for daily or recurring maintenance operations in RFC3339 format"
  type        = string
}

variable "max_pods_per_node" {
  description = "The maximum number of pods per node"
  type        = number
}

variable "max_nodes" {
  description = "Maximum number of nodes in the NodePool. Must be >= min_nodes"
  type        = number
}

variable "min_nodes" {
  description = "Minimum number of nodes in the NodePool. Must be >=0 and <= max_nodes. Should be used when autoscaling is true"
  type        = string
}

variable "node_pool_name" {
  description = "The name of the node pool"
  type        = string
}

variable "node_pools_tags" {
  description = "Map of lists containing node network tags by node-pool name"
  type        = map(list(string))
}

variable "project_id" {
  description = "The Project ID to host the cluster in"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
}

variable "enable_l4_ilb_subsetting" {
  description = "Enable L4 ILB subsetting"
  type        = bool
  default     = false
}

variable "enable_binary_authorization" {
  description = "Enable binary authorization"
  type        = bool
  default     = false
}
