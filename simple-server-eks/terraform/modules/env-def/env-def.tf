# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.

# NOTE:
# You need the EKS cluster name to be known already when creating VPC
# because it is needed in tags, and EKS glues things together using the tags.
locals {
  eks_cluster_name  = "${var.prefix}-${var.env}-ekscluster"
}


# The dynamodb tables.
module "dynamodb-tables" {
  source                    = "../dynamodb-tables"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  region                    = "${var.region}"
}

# EKS VPC.
module "vpc" {
  source                = "../vpc"
  prefix                = "${var.prefix}"
  env                   = "${var.env}"
  region                = "${var.region}"
  name                  = "eks-demo"
  eks_cluster_name      = "${local.eks_cluster_name}"
}

# NOTE: You need one ECR for each image.
module "ecr-repositories" {
  source                = "../ecr-repositories"
  prefix                = "${var.prefix}"
  env                   = "${var.env}"
  region                = "${var.region}"
}


# EKS with security groups, roles etc.
module "eks" {
  source                = "../eks"
  prefix                = "${var.prefix}"
  env                   = "${var.env}"
  region                = "${var.region}"
  name                  = "eks-demo"
  vpc_id                = "${module.vpc.vpc_id}"
  subnet_ids            = "${module.vpc.subnet_ids}"
  eks_cluster_name      = "${local.eks_cluster_name}"
  eks_worker_node_security_group_id = "${module.eks-worker-nodes.eks_worker_node_security_group_id}"
}

# EKS worker nodes, launch configuration, autoscaling group etc.
module "eks-worker-nodes" {
  source                    = "../eks-worker-nodes"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  region                    = "${var.region}"
  name                      = "eks-worker-node"
  vpc_id                    = "${module.vpc.vpc_id}"
  subnet_ids                = "${module.vpc.subnet_ids}"
  eks_cluster_certificate_authority_0_data = "${module.eks.eks_cluster_certificate_authority_0_data}"
  eks_cluster_endpoint              = "${module.eks.eks_cluster_endpoint}"
  eks_cluster_name                  = "${local.eks_cluster_name}"
  eks_cluster_security_group_id     = "${module.eks.eks_security_group_id}"
  dynamodb_arns                     = "${module.dynamodb-tables.all_dynamodb_arns_and_indeces_for_access_rights}"
}


