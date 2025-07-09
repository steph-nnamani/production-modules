output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat[*].id
  description = "List of NAT Gateway IDs"
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
  description = "CIDR block of the VPC"
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
  description = "Internet Gateway ID"
}

output "vpc_name" {
  value = "${var.name_prefix}-vpc"
  description = "VPC name tag value"
}

output "public_subnet_names" {
  value = [for i in range(length(var.public_subnet_cidrs)) : "${var.name_prefix}-public-${i + 1}"]
  description = "Public subnet name tag values"
}
