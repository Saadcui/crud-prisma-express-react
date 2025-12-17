output "eks_name" {
  value = aws_eks_cluster.cluster.name
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}
