provider "aws" {
  region = var.region
}

module "eks_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, list("cluster")))
  tags       = var.tags
}

locals {
  tags = merge(module.label.tags, map("kubernetes.io/cluster/${module.label.id}", "shared"))
}

module "vpc" {
  source             = "github.com/university-outreach-infrastructure-tf/terraform-networking-module.git//module?ref=0.2.0"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  attributes         = "${var.attributes}"
  name               = "${var.name}"
  cidr               = "${var.cidr_block}"
  private_subnets    = "${var.private_subnets}"
  public_subnets     = "${var.public_subnets}"
  availability_zones = "${var.availability_zones}"
}

module "eks_workers" {
  source                                 = "git::https://github.com/cloudposse/terraform-aws-eks-workers.git?ref=tags/0.10.0"
  namespace                              = var.namespace
  stage                                  = var.stage
  name                                   = var.name
  attributes                             = var.attributes
  tags                                   = var.tags
  instance_type                          = var.instance_type
  vpc_id                                 = module.vpc.vpc_id
  subnet_ids                             = module.subnets.public_subnet_ids
  associate_public_ip_address            = var.associate_public_ip_address
  health_check_type                      = var.health_check_type
  min_size                               = var.min_size
  max_size                               = var.max_size
  wait_for_capacity_timeout              = var.wait_for_capacity_timeout
  cluster_name                           = module.label.id
  cluster_endpoint                       = module.eks_cluster.eks_cluster_endpoint
  cluster_certificate_authority_data     = module.eks_cluster.eks_cluster_certificate_authority_data
  cluster_security_group_id              = module.eks_cluster.security_group_id
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
}

module "eks_cluster" {
  source                     = "git::https://https://github.com/cloudposse/terraform-aws-eks-cluster.git?ref=tags/0.6.0"
  namespace                  = var.namespace
  stage                      = var.stage
  name                       = var.name
  attributes                 = var.attributes
  tags                       = var.tags
  region                     = var.region
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.subnets.public_subnet_ids
  kubernetes_version         = var.kubernetes_version
  kubeconfig_path            = var.kubeconfig_path
  workers_role_arns          = [module.eks_workers.workers_role_arn]
  workers_security_group_ids = [module.eks_workers.security_group_id]
}