# The session dynamodb table.
module "dynamodb-session" {
  source                    = "../dynamodb"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  name                      = "session"
  hash_key_name             = "token"
  attributes_list           = [{name = "token"
                                type = "S"}]
}

# The users dynamodb table.
# NOTE: I should have named it "user" for consistency.
module "dynamodb-users" {
  source                    = "../dynamodb"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  name                      = "users"
  hash_key_name             = "email"
  attributes_list           = [{name = "email"
                                type = "S"}]
}

# The product-group dynamodb table.
module "dynamodb-product-group" {
  source                    = "../dynamodb"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  name                      = "product-group"
  hash_key_name             = "pgid"
  attributes_list           = [{name = "pgid"
                                type = "S"}]
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
  attribute      = [{name = "pid"
                     type = "S"},
                     {name = "pgid"
                      type = "S"}]
  tags {
    Name        = "${var.prefix}-${var.env}-product"
    Environment = "${var.prefix}-${var.env}"
    Terraform   = "true"
  }
}

