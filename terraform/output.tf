output "bastion_public_ip" {
  description = "Automatic pubic IP address of bastion host"
  value       = aws_instance.bastion.public_ip
}


output "dns_server_ip" {
  description = "Private IP of DNS server"
  value       = aws_instance.dns_server.private_ip
}

output "client_instance_ids" {
  description = "Instance IDs for SSM access"
  value = {
    client1 = aws_instance.client1.id
    client2 = aws_instance.client2.id
  }
}

output "ssh_command" {
  description = "SSH command to connect to bastion"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.bastion.public_ip}"
}
