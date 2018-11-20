#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Usage: ./dynamodb-put-item.sh <item-string>"
  exit 1
fi

ITEM=$1


# Test putting item to session dynamodb-table, ...
aws dynamodb put-item --profile tmv-test --table sseks-dev-session --item "{\"token\": {\"S\": \"$ITEM\"}}"

# ... then query it.
aws dynamodb scan --profile tmv-test --table sseks-dev-session
