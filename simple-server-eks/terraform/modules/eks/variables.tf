variable "prefix" {}
variable "env" {}
variable "region" {}
variable "name" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}
variable "eks_cluster_name" {}
variable "eks_worker_node_security_group_id" {}
