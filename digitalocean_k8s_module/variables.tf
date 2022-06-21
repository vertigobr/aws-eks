variable "cluster_name" {
  type        = string
  description = "Kubernetes Cluster Name"
}

variable "prefix_version" {
  type        = string
  description = "Define minor version for the Kubernetes cluster"
}

variable "region" {
  type        = string
  description = "Region where the cluster will be deployed"
}

variable "node_pool_default" {
  type = object({
    name       = string
    size       = string
    node_count = number
    auto_scale = optional(bool)
    min_nodes  = optional(number)
    max_nodes  = optional(number)
  })
  description = "Default node pool"
}

variable "additional_node_pools" {
  type = map(object({
    name       = string
    size       = string
    node_count = number
    auto_scale = optional(bool)
    min_nodes  = optional(number)
    max_nodes  = optional(number)
  }))
  description = "Additional node pools for the cluster"
  default     = {}
}
