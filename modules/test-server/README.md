## This module expects:
id_rsa (private key)
id_rsa.pub (public key)
- Create SSH Key Pair:
----------------------
# In the test-server module directory, run:
ssh-keygen -t rsa -b 2048 -f id_rsa -N ""
- This creates:
        id_rsa (private key)
        id_rsa.pub (public key)

## What Happens When You Deploy:
1. Finds latest Ubuntu AMI
2. Creates security group (wide open)
3. Generates unique key pair name
4. Uploads your public key to AWS
5. Launches EC2 instance in default VPC
6. SSH connects and installs git/docker

# AWS Default Behavior:
- Security Group: When vpc_id is omitted, AWS uses the default VPC
- EC2 Instance: When subnet_id is omitted, AWS picks a default subnet (usually public)
- Default VPC: Every AWS account has one per region with internet access pre-configured

# To Deploy in Custom VPC - Required Changes:
1. Add Variables to variables.tf:

variable "vpc_id" {
  description = "VPC ID where the instance will be deployed"
  type = string
  default = null  # null = use default VPC
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type = string
  default = null  # null = use default subnet
}

2. Update main.tf:

resource "aws_security_group" "instance" {
  name   = "testing-sec-group"
  vpc_id = var.vpc_id  # Now uses custom VPC if provided
  # ... rest of config
}

resource "aws_instance" "test-server" {
  # ... other config
  subnet_id = var.subnet_id  # Now uses custom subnet if provided
  # ... rest of config
}

3. Root Module Usage:

# Deploy in custom VPC
module "test_server" {
  source = "./modules/test-server"
  
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]  # First public subnet
}

# Deploy in default VPC (current behavior)
module "test_server" {
  source = "./modules/test-server"
  # vpc_id and subnet_id omitted = uses defaults
}

### Creating infrastructure/Instance with existing VPC
======================================================
- Option 1: Different Root Modules (Remote State)
- If VPC is in a separate Terraform project:
# Root Module (main.tf)
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "your-terraform-state-bucket"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

module "test_server" {
  source = "./modules/test-server"
  
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
}

- Option 2: Data Sources (If you know the names)
# Root Module (main.tf)
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["your-vpc-name"] # ← Replace with your actual VPC name
  }
}

data "aws_subnet" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "tag:Type"
    values = ["Public"]  # ← Replace with your actual tag value
  }
}

module "test_server" {
  source = "./modules/test-server"
  
  vpc_id = data.aws_vpc.existing.id
  subnet_id = data.aws_subnet.existing.id
}
