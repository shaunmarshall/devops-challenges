output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "ami_id" {
  value = data.aws_ami.amazon-linux-2.id
}

output "bastion_host_ip" {
  value = aws_instance.bastion.public_ip
}

output "app_instance_ips" {
  description = "Private IPs of the application instances"
  value       = aws_instance.app[*].private_ip
}
