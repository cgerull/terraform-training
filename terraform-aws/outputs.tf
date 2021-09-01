output ubuntu_public_ip {
    description = "Assign public IP address"
    value       = aws_instance.web_server.public_ip
}