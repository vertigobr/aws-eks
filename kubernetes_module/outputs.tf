output "root_secret_token" {
  value       = kubernetes_secret.root.data.token
  sensitive   = true
}

output "admin_secret_token" {
  value       = kubernetes_secret.admin.data.token
  sensitive   = true
}
