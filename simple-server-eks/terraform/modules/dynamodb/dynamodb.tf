
resource "aws_dynamodb_table" "dynamodb-instance" {
  name           = "${var.prefix}-${var.env}-${var.db_name}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "${var.hash_key_name}"

  attribute = [ "${var.attributes_list}" ]

  tags {
    Name        = "${var.prefix}-${var.env}-${var.db_name}"
    Environment = "${var.env}"
    Terraform   = "true"
  }
}
