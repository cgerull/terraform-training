# output ubuntu_public_ip {
#     description = "Assign public IP address"
#     value       = aws_instance.web_server.public_ip
# }
output "alb_dns_name" {
  description = "DNS name of the loadbalancer"
  value       = aws_lb.web_server.dns_name
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the Security Group attached to the load balancer"
}
