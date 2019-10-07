resource "aws_eks_cluster" "uwm_eks_cluster" {
  name            = format("%s-eks-cluster", module.gitlab_label.name)
  role_arn        = aws_iam_role.demo-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids         = [module.networking.public_subnets.*.id]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.uwm_eks_cluster_AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.uwm_eks_cluster_AmazonEKSServicePolicy",
  ]
}