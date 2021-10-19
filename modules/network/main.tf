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

locals {
  subnet         = format("%s-%s-01", var.network, var.region)
  pod_range      = format("%s-%s-pods-01", var.network, var.region)
  services_range = format("%s-%s-svcs-01", var.network, var.region)

  subnet_key = format("%s/%s", var.region, local.subnet)
}

# Create new VPC
module "vpc" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 3.4.0"

  project_id   = var.project_id
  network_name = var.network

  shared_vpc_host = false
}

# Some firewall rules required for Sonobuoy's mutating webhooks and other things
module "vpc-firewall" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.project_id
  network_name = module.vpc.network_name

  rules = [{
    name                    = "deny-all-ingress" # Catch-all firewall rule to help debugging
    description             = null
    direction               = "INGRESS"
    priority                = 65000
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow                   = []
    deny = [{
      protocol = "all"
      ports    = null
    }]
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
}

# Create subnets and secondary ranges in VPC
module "subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 3.4.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  subnets = [
    {
      subnet_name           = local.subnet
      subnet_ip             = var.cidr_range
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
    (local.subnet) = [
      {
        range_name    = local.pod_range
        ip_cidr_range = var.cidr_range_pods
      },
      {
        range_name    = local.services_range
        ip_cidr_range = var.cidr_range_services
      }
    ]
  }
}

# Add Cloud Router for Cloud NAT
module "cloud-router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 1.2.0"

  name    = format("%s-cr", module.vpc.network_name)
  project = var.project_id
  region  = var.region
  network = module.vpc.network_name
}

# Add Cloud NAT
module "cloud-nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "~> 2.0.0"

  project_id = var.project_id
  region     = var.region
  router     = module.cloud-router.router.name
}
