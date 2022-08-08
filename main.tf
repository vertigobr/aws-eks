module "cluster" {
  source  = "gitlab.com/vkpr/terraform-digitalocean-cluster/digitalocean"
  version = "~> 1.0.0"

  cluster_name          = local.config.cluster_name
  cluster_region        = local.config.cluster_region
  prefix_version        = local.config.prefix_version
  node_pool_default     = local.config.node_pool_default
  additional_node_pools = local.config.additional_node_pools
  tags                  = local.config.tags
}

module "kubernetes" {
  source  = "gitlab.com/vkpr/terraform-kubernetes-rbac/kubernetes"
  version = "~> 1.1.0"

  users_list             = local.config.users_list
  cluster_endpoint       = module.cluster.cluster_endpoint
  cluster_ca_certificate = module.cluster.cluster_certificate_authority_data
  cluster_access_token   = module.cluster.kubeconfig_token

  depends_on = [module.cluster]
}

module "kubeconfig" {
  source  = "gitlab.com/vkpr/terraform-kubernetes-kubeconfig/kubernetes"
  version = "~> 1.1.0"

  users_list             = local.config.users_list
  cluster_name           = local.config.cluster_name
  cluster_endpoint       = module.cluster.cluster_endpoint
  cluster_ca_certificate = module.cluster.cluster_certificate_authority_data
  cluster_access_token   = module.kubernetes.secrets_access_tokens

  depends_on = [module.kubernetes]
}
