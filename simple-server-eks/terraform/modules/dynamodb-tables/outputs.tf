
output "all_dynamodb_arns_and_indeces_for_access_rights" {
  value = ["${module.dynamodb-session.dynamodb_arn}",
    "${module.dynamodb-users.dynamodb_arn}",
    "${module.dynamodb-product-group.dynamodb_arn}",
    "${aws_dynamodb_table.product-dynamodb-instance.arn}",
    # NOTE: You have to give access right to the indeces as well.
    "${aws_dynamodb_table.product-dynamodb-instance.arn}/index/PGIndex"
    ]
}




