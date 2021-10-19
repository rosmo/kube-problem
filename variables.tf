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

variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region to deploy GKE into"
  default     = "europe-west4"
}

variable "network" {
  type        = string
  description = "VPC name"
  default     = "kube-problem"
}

variable "cidr_range" {
  type        = string
  description = "Subnet CIDR"
  default     = "192.168.144.0/24"
}

variable "cidr_range_pods" {
  type        = string
  description = "GKE pod CIDR"
  default     = "192.168.128.0/20"
}

variable "cidr_range_services" {
  type        = string
  description = "GKE services CIDR"
  default     = "192.168.145.0/24"
}

variable "cidr_range_controlplane" {
  type        = string
  description = "GKE control plane range (/28)"
  default     = "192.168.147.0/28"
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name"
  default     = "kube-problem"
}

variable "cluster_instance_type" {
  type        = string
  description = "GKE cluster instance type"
  default     = "e2-standard-4"
}
