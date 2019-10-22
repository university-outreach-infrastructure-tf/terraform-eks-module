resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = format("%s-%s-eks-cluster-", module.gitlab_label.name, module.gitlab_label.stage)
  description = "Cluster communication with worker nodes"
  vpc_id      = module.networking.vpc_id
  tags        = { "Name" = format("%s-eks-cluster",module.gitlab_label.name),"Environment" = module.gitlab_label.stage }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}