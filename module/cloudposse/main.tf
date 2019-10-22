module "eks_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, list("cluster")))
  tags       = { "Name" = var.name, "Environment" = var.stage }
}

locals {
  tags = merge(module.eks_label.tags, map("kubernetes.io/cluster/${module.eks_label.id}", "shared"))
}

module "eks_vpc" {
  source             = "github.com/university-outreach-infrastructure-tf/terraform-networking-module.git//module?ref=0.2.0"
  namespace          = var.namespace
  stage              = var.stage
  attributes         = var.attributes
  name               = var.name
  cidr               = var.cidr_block
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

module "eks_workers" {
  source                                 = "git::https://github.com/cloudposse/terraform-aws-eks-workers.git?ref=tags/0.10.0"
  namespace                              = var.namespace
  stage                                  = var.stage
  name                                   = var.name
  attributes                             = var.attributes
  tags                                   = var.tags
  instance_type                          = var.instance_type
  vpc_id                                 = module.eks_vpc.vpc_id
  subnet_ids                             = flatten([module.eks_vpc.public_subnets])
  associate_public_ip_address            = var.associate_public_ip_address
  health_check_type                      = var.health_check_type
  min_size                               = var.eks_asg_min_size
  max_size                               = var.eks_asg_max_size
  wait_for_capacity_timeout              = var.wait_for_capacity_timeout
  cluster_name                           = module.eks_label.id
  cluster_endpoint                       = module.eks_cluster.eks_cluster_endpoint
  cluster_certificate_authority_data     = module.eks_cluster.eks_cluster_certificate_authority_data
  cluster_security_group_id              = module.eks_cluster.security_group_id
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
}

module "eks_cluster" {
  source                     = "git::https://github.com/cloudposse/terraform-aws-eks-cluster.git?ref=tags/0.6.0"
  namespace                  = var.namespace
  stage                      = var.stage
  name                       = var.name
  attributes                 = var.attributes
  tags                       = var.tags
  region                     = var.region
  vpc_id                     = module.eks_vpc.vpc_id
  subnet_ids                 = flatten([module.eks_vpc.public_subnets])
  kubernetes_version         = var.kubernetes_version
  kubeconfig_path            = var.kubeconfig_path
  workers_role_arns          = [module.eks_workers.workers_role_arn]
  workers_security_group_ids = [module.eks_workers.security_group_id]
}