
output "eks_security_group_name" {
  value = "${aws_security_group.eks-security-group.name}"
}

output "eks_security_group_id" {
  value = "${aws_security_group.eks-security-group.id}"
}

output "eks_cluster_name" {
  value = "${aws_eks_cluster.eks-cluster.name}"
}

output "eks_cluster_endpoint" {
  value = "${aws_eks_cluster.eks-cluster.endpoint}"
}

output "eks_cluster_certificate_authority_0_data" {
  value = "${aws_eks_cluster.eks-cluster.certificate_authority.0.data}"
}




