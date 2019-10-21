module "eks_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = var.attributes
  delimiter  = var.delimiter
  tags       = { "Name" = var.name, "Environment" = var.stage }
}