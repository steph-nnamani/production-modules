output "public_ip" {
  value = aws_instance.test-server.public_ip
  description = "Public IP address of the test server"
}

output "ssh_command" {
  value = "ssh -i ${path.module}/id_rsa ubuntu@${aws_instance.test-server.public_ip}"
  description = "Complete SSH command to connect to the server"
}

output "ssh_user" {
  value = "ubuntu"
  description = "SSH username"
}

output "private_key_path" {
  value = "${path.module}/id_rsa"
  description = "Path to the private key file"
}

output "instance_id" {
  value = aws_instance.test-server.id
  description = "EC2 instance ID"
}