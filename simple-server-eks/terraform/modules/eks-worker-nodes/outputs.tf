
output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}


output "eks_worker_node_security_group_name" {
  value = "${aws_security_group.eks-worker-node-security-group.name}"
}

output "eks_worker_node_security_group_id" {
  value = "${aws_security_group.eks-worker-node-security-group.id}"
}
