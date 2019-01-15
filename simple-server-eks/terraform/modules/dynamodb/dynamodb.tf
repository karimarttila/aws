locals {
  my_name  = "${var.prefix}-${var.env}-${var.name}"
  my_env   = "${var.prefix}-${var.env}"
}

resource "aws_dynamodb_table" "dynamodb-instance" {
  name           = "${local.my_name}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "${var.hash_key_name}"
  attribute      = [ "${var.attributes_list}" ]

  tags {
    Name        = "${local.my_name}"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}
