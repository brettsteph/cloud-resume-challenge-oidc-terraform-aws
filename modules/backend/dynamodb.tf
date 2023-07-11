# DynamoDb
resource "aws_dynamodb_table" "table" {
  name         = "cloud-resume-challenge"
  billing_mode = "PAY_PER_REQUEST"

  lifecycle {
    create_before_destroy = true # if true an error is thrown
  }

  attribute {
    name = "siteUrl"
    type = "S"
  }
  hash_key = "siteUrl"

  table_class = "STANDARD"

  tags = {
    Name = "cloud-resume-challenge"
  }
}

# Add table item visit = 0 in order for Boto3 update_item function to work
resource "aws_dynamodb_table_item" "example" {
  table_name = aws_dynamodb_table.table.name
  hash_key   = aws_dynamodb_table.table.hash_key

  lifecycle {
    ignore_changes = [
      item
    ]
  }

  item = <<ITEM
{
  "siteUrl": {"S": "${var.sub_domain}"},
  "visits": {"N": "0"}
}
ITEM
}
