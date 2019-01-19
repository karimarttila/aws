
output "all_dynamodb_arns" {
  value = ["${module.dynamodb-session.dynamodb_arn}",
    "${module.dynamodb-users.dynamodb_arn}",
    "${module.dynamodb-product-group.dynamodb_arn}",
    "${aws_dynamodb_table.product-dynamodb-instance.arn}"]
}




