terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "asg" {
  source = "../../cluster/asg-rolling-deploy"
  target_group_arns  = [aws_lb_target_group.app.arn]  # Direct reference
  cluster_name           = "hello-world-${var.environment}"
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  instance_type_alternate = var.instance_type_alternate
  server_port            = var.server_port
  
  db_remote_state_bucket = var.db_remote_state_bucket
  db_remote_state_key    = var.db_remote_state_key

  min_size           = var.min_size
  max_size           = var.max_size
  health_check_type  = "ELB"
  enable_autoscaling = var.enable_autoscaling
  custom_tags        = var.custom_tags

  subnet_ids = data.aws_subnets.default.ids

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address  = try(data.terraform_remote_state.db.outputs.address)
    db_port     = try(data.terraform_remote_state.db.outputs.port)
    server_text = var.server_text
  }))
}

module "alb" {
  source = "../../networking/alb"

  alb_name   = "hello-world-${var.environment}"
  subnet_ids = data.aws_subnets.default.ids
}

# module "integration" {
#   source = "../../integration-layer/TGs-and-Listener-rules"

#   environment  = var.environment
#   server_port  = var.server_port
#   vpc_id       = data.aws_vpc.default.id
#   listener_arn = module.alb.alb_http_listener_arn
# }

resource "aws_lb_target_group" "app" {
    name = "hello-world-${var.environment}"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id
    
    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = module.alb.alb_http_listener_arn  # Use ALB module output 
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.app.arn
    }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "us-east-1"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}













