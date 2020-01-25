
output "all_dynamodb_arns_and_indeces_for_access_rights" {
  value = [
    "${aws_dynamodb_table.session-dynamodb-instance.arn}",
    "${aws_dynamodb_table.users-dynamodb-instance.arn}",
    "${aws_dynamodb_table.product-group-dynamodb-instance.arn}",
    "${aws_dynamodb_table.product-dynamodb-instance.arn}",
    # NOTE: You have to give access right to the indices as well.
    "${aws_dynamodb_table.product-dynamodb-instance.arn}/index/PGIndex"
    ]
}


