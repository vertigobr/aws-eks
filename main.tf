module "cluster" {
  source  = "gitlab.com/vkpr/terraform-aws-eks/aws"
  version = "~> 1.3.0"

  cluster_name              = local.config.cluster_name
  cluster_version           = local.config.cluster_version
  cidr_block                = local.config.cidr_block
  private_subnets           = local.config.private_subnets
  public_subnets            = local.config.public_subnets
  node_groups               = local.config.node_groups
  tags                      = local.config.tags
  cluster_enabled_log_types = try(local.config.cluster_enabled_log_types, [""])
  aws_availability_zones    = try(local.config.aws_availability_zones, [""])
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
