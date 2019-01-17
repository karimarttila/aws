
# ECR for EKS - karimarttila/debian-openjdk11
module "ecr-debian-openjdk11" {
  source                = "../ecr"
  prefix                = "${var.prefix}"
  env                   = "${var.env}"
  region                = "${var.region}"
  name                  = "eks-ecr/karimarttila/debian-openjdk11"
}

# ECR for EKS - karimarttila/simple-server-clojure-single-node
module "ecr-simple-server-clojure-single-node" {
  source                = "../ecr"
  prefix                = "${var.prefix}"
  env                   = "${var.env}"
  region                = "${var.region}"
  name                  = "eks-ecr/karimarttila/simple-server-clojure-single-node"
}

# ECR for EKS - karimarttila/karimarttila/simple-server-clojure-dynamodb
module "ecr-simple-server-clojure-dynamodb" {
  source                = "../ecr"
  prefix                = "${var.prefix}"
  env                   = "${var.env}"
  region                = "${var.region}"
  name                  = "eks-ecr/karimarttila/simple-server-clojure-dynamodb"
}
