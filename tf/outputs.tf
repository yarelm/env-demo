/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "host_project_id" {
  value       = module.host-project.project_id
  description = "The ID of the created project"
}

output "host_project" {
  value       = module.host-project
  description = "The full host project info"
}

# output "service_project" {
#   value       = module.service-project
#   description = "The service project info"
# }


output "vpc" {
  value       = module.gcp-network
  description = "The network info"
}

output "network_name" {
  value       = module.gcp-network.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.gcp-network.network_self_link
  description = "The URI of the VPC being created"
}

output "subnets" {
  value       = module.gcp-network.subnets_self_links
  description = "The shared VPC subets"
}
