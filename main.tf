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

module "aws_ebs_csi_driver_iam" {
  source                      = "github.com/andreswebs/terraform-aws-eks-ebs-csi-driver//modules/iam"
  version = "~> 1.1.0"
  cluster_oidc_provider       = ""
  k8s_namespace               = "kube-system"
  iam_role_name               = "ebs-csi-controller-${local.config.cluster_name}"
}
module "aws_ebs_csi_driver_resources" {
  source                           = "github.com/andreswebs/terraform-aws-eks-ebs-csi-driver//modules/resources"
  version = "~> 1.1.0"
  cluster_name                     = local.config.cluster_name
  iam_role_arn                     = var.aws_ebs_csi_driver_iam_role_arn
  chart_version_aws_ebs_csi_driver = var.chart_version_aws_ebs_csi_driver
}
