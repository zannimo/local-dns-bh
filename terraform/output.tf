output "dns_server_ip" {
  description = "Private IP of DNS server"
  value       = aws_instance.dns_server.private_ip
}

output "SSM_command_dns_server" {
  description = "SSM command to connect to the DNS server"
  value       = "aws ssm start-session --target ${aws_instance.dns_server.id}"
}

output "SSM_command_client1" {
  description = "SSM command to connect to the client 1"
  value       = "aws ssm start-session --target ${aws_instance.client1.id}"
}

output "SSM_command_client2" {
  description = "SSM command to connect to the client 2"
  value       = "aws ssm start-session --target ${aws_instance.client2.id}"
}

