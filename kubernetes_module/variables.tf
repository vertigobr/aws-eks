variable "cluster_name" {
  type        = string
  description = "Kubernetes Cluster Name"
}

variable "root_access" {
  description = "Se `true` o arquivo kubeconfig será criado com o usuário super-admin."
  type        = bool
  default     = false
}

variable "cluster_endpoint" {
  description = "Endereço do endpoint do CP do cluster."
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Certificado de acesso ao CP."
  type        = string
}

variable "cluster_access_token" {
  description = "Token para acesso ao cluster."
  type        = string
}

