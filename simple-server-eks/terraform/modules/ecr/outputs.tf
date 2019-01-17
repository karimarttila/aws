
output "ecr_name" {
  value = "${aws_ecr_repository.eks-ecr-repository.name}"
}

output "ecr_id" {
  value = "${aws_ecr_repository.eks-ecr-repository.id}"
}
