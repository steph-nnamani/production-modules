# How to use this module
# In your root config:

module "vpc" {
  source = "./modules/vpc"  # ✅ Correct path
  
  # Basic Configuration
  name_prefix = "prod"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # Production Settings
  single_nat_gateway = false    # ✅ High availability
  enable_flow_logs = true       # ✅ Security monitoring
  
  # Tags
  tags = {
    Environment = "production"
    Project = "my-app"
    Owner = "platform-team"
  }
}

## VPC Module Components Explained:

# Core Infrastructure:
- VPC: Creates isolated network (like your own data center in AWS)

- Internet Gateway: Allows internet access (like a router to the internet)

- DNS enabled: Resources can resolve domain names

# Public subnets:
- Public subnets: Resources get public IP addresses

- Multi-AZ: Spread across availability zones for redundancy

- Route to IGW: Traffic goes directly to internet via Internet Gateway

# Private subnets:
- Private subnets: No direct internet access

- Internal communication: Can talk to other AWS resources

- Route to NAT: Internet traffic goes through NAT Gateway

# NAT Gateway System:
How it works:
-------------
- Elastic IP: Static public IP address

- NAT Gateway: Sits in public subnet, translates private → public traffic

- Two modes:
    HA Mode: One NAT per AZ (expensive but resilient)
    Cost Mode: Single NAT for all private subnets

# Routing Logic:
- Public Route: Internet → IGW → Public Subnet
Public Subnet → Route Table → 0.0.0.0/0 → Internet Gateway

- Private Route: Private Subnet → NAT → IGW → Internet
Private Subnet → Route Table → 0.0.0.0/0 → NAT Gateway → Internet Gateway

# Security Monitoring:
aws_flow_log + aws_cloudwatch_log_group + IAM roles

- VPC Flow Logs: Records all network traffic (who talked to whom)

- CloudWatch: Stores logs for 30 days

- IAM Role: Permissions for Flow Logs to write to CloudWatch

## Traffic Flow Examples:
# - Outbound Internet Access:
EC2 in Private Subnet → Private Route Table → NAT Gateway → Internet Gateway → Internet

# - Inbound Internet Access:
Internet → Internet Gateway → Public Subnet → Load Balancer → Private Subnet

# Internal Communication:
Private Subnet A ↔ Private Subnet B (direct, no NAT needed)

## Key Design Decisions:
- Multi-AZ Design: Resources spread across AZs for high availability
- Conditional NAT: Choose between cost (single) vs availability (multiple)
- Security First: Private subnets by default, Flow Logs for monitoring
- Flexible: Variables control behavior without code changes

This creates a production-ready network foundation that's secure, scalable, and cost-configurable.
