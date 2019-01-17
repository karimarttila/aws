locals {
  my_name  = "${var.prefix}-${var.env}-${var.name}"
  my_env   = "${var.prefix}-${var.env}"
}


# Using example provided in
# https://github.com/terraform-providers/terraform-provider-aws/blob/master/examples/eks-getting-started/eks-cluster.tf
# With some of my own conventions.

resource "aws_iam_role" "eks-iam-role" {
  name = "${local.my_name}-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-iam-role.name}"
}


resource "aws_security_group" "eks-security-group" {
  name        = "${local.my_name}-eks-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name        = "${local.my_name}-eks-security-group"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}

resource "aws_security_group_rule" "eks-node-https-ingress-rule" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-security-group.id}"
  source_security_group_id = "${var.eks_worker_node_security_group_id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_eks_cluster" "eks-cluster" {
  # NOTE: We need to use the cluster name we gave to VPC module
  # Since the name is used in VPC tag and EKS glues things together using that tag.
  name     = "${var.eks_cluster_name}"
  role_arn = "${aws_iam_role.eks-iam-role.arn}"
  version = "1.11"


  vpc_config {
    security_group_ids = ["${aws_security_group.eks-security-group.id}"]
    subnet_ids         = ["${var.subnet_ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-cluster-policy",
    "aws_iam_role_policy_attachment.eks-service-policy",
  ]
}