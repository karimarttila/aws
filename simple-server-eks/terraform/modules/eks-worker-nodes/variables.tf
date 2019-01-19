variable "prefix" {}
variable "env" {}
variable "region" {}
variable "name" {}
variable "vpc_id" {}
variable "eks_cluster_security_group_id" {}
variable "eks_cluster_name" {}
variable "eks_cluster_endpoint" {}
variable "eks_cluster_certificate_authority_0_data" {}
variable "subnet_ids" {
  type = "list"
}
variable "dynamodb_arns" {
  type = "list"
}


