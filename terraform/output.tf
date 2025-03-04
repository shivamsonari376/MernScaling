output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
}

output "frontend_public_ip" {
  value = aws_instance.frontend_server.public_ip
}
