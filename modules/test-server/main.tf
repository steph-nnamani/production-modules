# # Get latest Amazon Linux AMI
# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# Get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "instance" {
    name = "testing-sec-group"
    vpc_id = var.vpc_id  # Now uses custom VPC if provided

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

        # from_port = 8080
        # to_port = 8080
        # protocol = "tcp"
        # cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "random_id" "key_suffix" {
  byte_length = 4
}

resource "aws_key_pair" "test-key" {
    key_name = "test-key-${random_id.key_suffix.hex}"
    public_key = file("${path.module}/id_rsa.pub")
}

resource "aws_instance" "test-server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = aws_key_pair.test-key.key_name
    subnet_id = var.subnet_id  # Now uses custom subnet if provided
    vpc_security_group_ids = [aws_security_group.instance.id]
    tags = {
        Name = var.server_name
    }
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = file("${path.module}/id_rsa")
        timeout = "2m"
    }
    # Conditional provisioner based on variable
    provisioner "remote-exec" {
        inline = var.enable_provisioner ? [
            "sudo apt update -y",
            "sudo apt install -y git",
            "sudo apt install -y docker.io",
            "sudo systemctl start docker",
            "sudo usermod -aG docker ubuntu",
        ] : ["echo 'Provisioning skipped'"]
    }
}
