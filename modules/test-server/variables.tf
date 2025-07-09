variable "vpc_id" {
  description = "VPC ID where the instance will be deployed"
  type = string
  default = null  # ← Key: null means "use AWS default"
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type = string
  default = null  # null = use default subnet
}   

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  
  validation {
    condition = contains(["t2.micro", "t3.micro", "t3.nano"], var.instance_type)
    error_message = "Invalid instance type. Please choose from t2.micro, t3.micro, or t3.nano."
  }
}

variable "server_name" {
  description = "Name tag for the test server"
  type = string
  default = "test-server"
}

variable "enable_provisioner" {
  description = "Whether to install software (git, docker) on the instance"
  type = bool
  default = true
}
