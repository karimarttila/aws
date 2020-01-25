locals {
  my_name  = "${var.prefix}-${var.env}-${var.name}"
  my_env   = "${var.prefix}-${var.env}"
}

# Using example provided in
# https://github.com/terraform-providers/terraform-provider-aws/blob/master/examples/eks-getting-started/vpc.tf
# With some of my own conventions.

data "aws_availability_zones" "available" {}

resource "aws_vpc" "eks-vpc" {
  cidr_block = "10.10.0.0/23"

  tags = "${
    map(
     "Name", "${local.my_name}-vpc",
     "Environment", "${local.my_env}",
     "Terraform", "true",
     "kubernetes.io/cluster/${var.eks_cluster_name}", "shared",
    )
  }"
}

resource "aws_subnet" "eks-subnet" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.10.${count.index}.0/24"
  vpc_id            = "${aws_vpc.eks-vpc.id}"

  tags = "${
    map(
     "Name", "${local.my_name}-subnet-${count.index}",
     "Environment", "${local.my_env}",
     "Terraform", "true",
     "kubernetes.io/cluster/${var.eks_cluster_name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "eks-internet-gateway" {
  vpc_id = "${aws_vpc.eks-vpc.id}"

  tags = {
    Name        = "${local.my_name}-internet-gateway"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}

resource "aws_route_table" "eks-route-table" {
  vpc_id = "${aws_vpc.eks-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks-internet-gateway.id}"
  }

  tags = {
    Name        = "${local.my_name}-route-table"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}

resource "aws_route_table_association" "eks-route-table-association" {
  count = 2

  subnet_id      = "${aws_subnet.eks-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks-route-table.id}"
}