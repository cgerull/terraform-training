# output ubuntu_public_ip {
#     description = "Assign public IP address"
#     value       = aws_instance.web_server.public_ip
# }
output "alb_dns_name" {
    description = "DNS name of the loadbalancer"
    value       = aws_lb.web_server.dns_name
}