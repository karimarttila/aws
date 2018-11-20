# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.


# The session dynamodb table.
module "dynamodb-session" {
  source                    = "../dynamodb"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  db_name                   = "session"
  hash_key_name             = "token"
  attributes_list           = [{name = "token"
                                type = "S"}]
}