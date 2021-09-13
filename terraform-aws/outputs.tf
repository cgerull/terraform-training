# output ubuntu_public_ip {
#     description = "Assign public IP address"
#     value       = aws_instance.web_server.public_ip
# }
output "alb_dns_name" {
  description = "DNS name of the loadbalancer"
  value       = aws_lb.web_server.dns_name
}

# Output for backend state storage
#
# output "s3_bucket_arn" {
#   description = "The ARN of the state S3 bucket"
#   value = aws_s3_bucket.terraform_state.arn
# }

# output "dynamodb_table_name" {
#   description = "The name of the DynamoDB table"
#   value = aws_dynamodb_table.terraform_locks.name
# }