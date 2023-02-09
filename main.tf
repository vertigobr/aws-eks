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
    
 data "aws_eks_cluster" "eks" {
  name              = local.config.cluster_name
  depends_on = [module.cluster]
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  depends_on = [module.cluster]
}
 
module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${local.config.cluster_name}"
  provider_url                  = replace(data.aws_eks_cluster.eks.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
  depends_on = [module.kubernetes]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = local.config.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.5.2-eksbuild.1"
  preserve                 = true
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
  depends_on = [module.cluster]  
}
