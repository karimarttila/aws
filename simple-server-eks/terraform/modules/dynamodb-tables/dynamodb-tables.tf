
resource "aws_dynamodb_table" "session-dynamodb-instance" {
  name = "${var.prefix}-${var.env}-session"
  read_capacity = 5
  write_capacity = 5
  hash_key       = "token"
  attribute {
    name = "token"
    type = "S"
  }
  tags = {
    Name        = "${var.prefix}-${var.env}-session"
    Environment = "${var.prefix}-${var.env}"
    Terraform   = "true"
  }
}

resource "aws_dynamodb_table" "users-dynamodb-instance" {
  name = "${var.prefix}-${var.env}-users"
  read_capacity = 5
  write_capacity = 5
  hash_key       = "email"
  attribute {
    name = "email"
    type = "S"
  }
  tags = {
    Name        = "${var.prefix}-${var.env}-users"
    Environment = "${var.prefix}-${var.env}"
    Terraform   = "true"
  }
}


resource "aws_dynamodb_table" "product-group-dynamodb-instance" {
  name = "${var.prefix}-${var.env}-product-group"
  read_capacity = 5
  write_capacity = 5
  hash_key       = "pgid"
  attribute {
    name = "pgid"
    type = "S"
  }
  tags = {
    Name        = "${var.prefix}-${var.env}-product-group"
    Environment = "${var.prefix}-${var.env}"
    Terraform   = "true"
  }
}

# The product dynamodb table is a bit different because of secondary index.
# Let's create it directly here.
resource "aws_dynamodb_table" "product-dynamodb-instance" {
  name           = "${var.prefix}-${var.env}-product"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "pid"
  range_key      = "pgid"
  global_secondary_index {
    name               = "PGIndex"
    hash_key           = "pgid"
    range_key          = "pid"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "INCLUDE"
    non_key_attributes = ["price", "title"]
  }
  attribute {
    name = "pid"
    type = "S"
  }
  attribute {
    name = "pgid"
    type = "S"
  }

  tags = {
    Name        = "${var.prefix}-${var.env}-product"
    Environment = "${var.prefix}-${var.env}"
    Terraform   = "true"
  }
}

