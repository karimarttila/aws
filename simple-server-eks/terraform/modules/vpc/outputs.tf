
output "vpc_id" {
  value = "${aws_vpc.eks-vpc.id}"
}

output "subnet_ids" {
  value = "${aws_subnet.eks-subnet.*.id}"
}

