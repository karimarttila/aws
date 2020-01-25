locals {
  my_name             = "${var.prefix}-${var.env}-${var.name}"
  my_env              = "${var.prefix}-${var.env}"
  my_private_key_name = "${local.my_name}-workder-node-key"
}

# Using example provided in
# https://github.com/terraform-providers/terraform-provider-aws/blob/master/examples/eks-getting-started/eks-worker-nodes.tf
# With some of my own conventions.


resource "aws_iam_role" "eks-worker-node-iam-role" {
  name = "${local.my_name}-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-worker-node-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-worker-node-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-ec2-container-registry-readonly-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-worker-node-iam-role.name}"
}


# I used the excellent AWS Policy Generator for this.
resource "aws_iam_role_policy" "eks-worker-node-dynamodb-role-policy" {
  name   = "${local.my_name}-dynamodb-role-policy"
  role   = "${aws_iam_role.eks-worker-node-iam-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDynamoDBAccess",
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": ${jsonencode(var.dynamodb_arns)}
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "eks-worker-node-instance-profile" {
  name = "${local.my_name}-instance-profile"
  role = "${aws_iam_role.eks-worker-node-iam-role.name}"
}

resource "aws_security_group" "eks-worker-node-security-group" {
  name = "${local.my_name}-security-group"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${local.my_name}-security-group",
     "Environment", "${local.my_env}",
     "Terraform", "true",
     "kubernetes.io/cluster/${var.eks_cluster_name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "eks-worker-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks-worker-node-security-group.id}"
  source_security_group_id = "${aws_security_group.eks-worker-node-security-group.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-worker-node-security-group.id}"
  source_security_group_id = "${var.eks_cluster_security_group_id}"
  to_port                  = 65535
  type                     = "ingress"
}


data "aws_ami" "eks-worker-node-ami" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  eks-worker-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_cluster_endpoint}' --b64-cluster-ca '${var.eks_cluster_certificate_authority_0_data}' '${var.eks_cluster_name}'
USERDATA
}


# NOTE: You need to "terraform init" to get the tls provider!
resource "tls_private_key" "ec2-ssh-key" {
  algorithm   = "RSA"
}

# NOTE: If you get 'No available provider "null" plugins'
# Try: terraform init, terraform get, terraform plan.
# I.e. resource occasionally fails the first time.
# When the resource is succesfull you should see the private key
# in ./terraform/.ssh folder.
# NOTE: Save this ssh key to bucket TODO if others need to use this machine.
# Linux version, if you need Windows version ask Kari to create it.
# NOTE: you need to create the .ssh directory in the env directory.
resource "null_resource" "ec2-save-ssh-key-linux" {
  triggers = {
    key = tls_private_key.ec2-ssh-key.private_key_pem
  }
  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.ec2-ssh-key.private_key_pem}" > ${path.root}/.ssh/${local.my_private_key_name}
      chmod 0600 ${path.root}/.ssh/${local.my_private_key_name}
EOF
  }
}


resource "aws_key_pair" "ec2-key-pair" {
  key_name   = local.my_private_key_name
  public_key = tls_private_key.ec2-ssh-key.public_key_openssh
}


resource "aws_launch_configuration" "eks-worker-node-launch-configuration" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks-worker-node-instance-profile.name}"
  # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
  image_id                    = "ami-0b9d2c11b47bd8264"
  # Let's try image 1.11 which is the current EKS version: amazon-eks-node-1.11-v20190109
  # OLD:image_id              = "ami-01e08d22b9439c15a"
  #image_id                   = "${data.aws_ami.eks-worker-node-ami.id}"
  instance_type               = "m4.large"
  name_prefix                 = "${local.my_name}-lc"
  security_groups             = ["${aws_security_group.eks-worker-node-security-group.id}"]
  user_data_base64            = "${base64encode(local.eks-worker-node-userdata)}"
  # For debugging worker nodes
  key_name                    = local.my_private_key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks-worker-node-autoscaling-group" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.eks-worker-node-launch-configuration.id}"
  max_size             = 2
  min_size             = 1
  name                 = "${local.my_name}-asc"
  vpc_zone_identifier  = flatten(["${var.subnet_ids}"])

  tag {
    key                 = "Name"
    value               = "${local.my_name}-instance"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = "${local.my_env}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-worker-node-iam-role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}
