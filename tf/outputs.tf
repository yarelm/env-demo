
output "host_project_id" {
  value       = module.host.host_project_id
  description = "The ID of the created host project"
}

output "tenants_project_id" {
  value = tomap({
  for k, bd in module.dev_envs : k => bd.tenant_project_id
  })
  description = "The ID of the created tenants project"
}

output "postgres_ip" {
  value = module.host.postgres_ip
}