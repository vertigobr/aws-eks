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
    
data "aws_eks_cluster" "cluster" {
  name = local.config.cluster_name
  depends_on = [module.cluster]  
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.config.cluster_name
  depends_on = [module.cluster]  
}

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  depends_on = [module.cluster]  
}

resource "aws_iam_openid_connect_provider" "openid_connect" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  depends_on = [module.cluster]  
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "ebs_csi_driver_controller" {
  source = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.5.0"

  ebs_csi_controller_image                   = ""
  ebs_csi_controller_role_name               = "ebs-csi-driver-controller"
  ebs_csi_controller_role_policy_name_prefix = "ebs-csi-driver-policy"
  oidc_url                                   = aws_iam_openid_connect_provider.openid_connect.url
  depends_on = [module.cluster]  
}
