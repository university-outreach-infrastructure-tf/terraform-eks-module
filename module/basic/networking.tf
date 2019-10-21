module "uwm_eks_cluster_vpc_mgmt" {
  source             = "github.com/university-outreach-infrastructure-tf/terraform-networking-module.git//module?ref=0.2.0"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  attributes         = "${var.attributes}"
  name               = "${var.name}"
  delimiter          = "${var.delimiter}"
  cidr               = "${var.cidr_block}"
  private_subnets    = "${var.private_subnets}"
  public_subnets     = "${var.public_subnets}"
  availability_zones = "${var.availability_zones}"
}

module "uwm_eks_cluster_vpc_app" {
  source             = "github.com/university-outreach-infrastructure-tf/terraform-networking-module.git//module?ref=0.2.0"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  attributes         = "${var.attributes}"
  name               = "${var.name}"
  delimiter          = "${var.delimiter}"
  cidr               = "${var.cidr_block}"
  private_subnets    = "${var.private_subnets}"
  public_subnets     = "${var.public_subnets}"
  availability_zones = "${var.availability_zones}"
}

aws s3api create-bucket \
--bucket uwm-test-bucket \
--region us-east-2