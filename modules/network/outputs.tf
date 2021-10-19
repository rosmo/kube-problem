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

output "network_name" {
  value = module.vpc.network_name
}

output "subnets" {
  value = module.subnets.subnets
}

output "gke_subnet" {
  value = module.subnets.subnets[local.subnet_key]
}

output "gke_pod_subnet" {
  value = element([for s in module.subnets.subnets[local.subnet_key].secondary_ip_range : s.range_name if s.range_name == local.pod_range], 0)
}

output "gke_services_subnet" {
  value = element([for s in module.subnets.subnets[local.subnet_key].secondary_ip_range : s.range_name if s.range_name == local.services_range], 0)
}
