terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Using Data Source with Precondition in a Module:
data "aws_ec2_instance_type" "instance" {
    instance_type = var.instance_type
}

# aws_launch_template
resource "aws_launch_template" "example" {
    name_prefix   = var.cluster_name
    image_id = var.ami
    instance_type = var.instance_type
    
    vpc_security_group_ids = [aws_security_group.instance.id]
    user_data = var.user_data
    
     
    # Required when using a launch template with an auto scaling group
    lifecycle {
        create_before_destroy = true
        precondition {
          condition = data.aws_ec2_instance_type.instance.free_tier_eligible
          error_message = "${var.instance_type} is not part of the AWS Free Tier"
        }
    }
}

# aws_autoscaling_group
resource "aws_autoscaling_group" "example" {
    # Explicitly depend on the launch template's name 
    # so each time it's replaced, this ASG is also replaced
    name_prefix = "${var.cluster_name}-"

    vpc_zone_identifier = var.subnet_ids
    target_group_arns = var.target_group_arns

    mixed_instances_policy {
        launch_template {
            launch_template_specification {
                launch_template_id = aws_launch_template.example.id
                version = "$Latest"  # Best practice to use actual versioned template
            }
            override {
                instance_type = var.instance_type # Use the same type from variables (no hardcode)
            }
            override {
                instance_type = var.instance_type_alternate # Use the same alternative type from variables (no hardcode)
            }
        }
        instances_distribution {
            on_demand_base_capacity = var.on_demand_base_capacity
            on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
            spot_allocation_strategy                 = var.spot_allocation_strategy  
        }
    }
    health_check_type = var.health_check_type
    min_size = var.min_size
    max_size = var.max_size
    
    # Wait for at least this many instances to pass health checks before 
    # considering the ASG deployment complete
    min_elb_capacity = var.min_size

    wait_for_capacity_timeout = "10m"
    # when replacing the ASG, Terraform will wait for the new ASG to be created
    # and the new ASG to be ready before destroying the old AS
    lifecycle {
        create_before_destroy = true
        ignore_changes = [load_balancers, target_group_arns]
        
        postcondition {
            condition = length(self.availability_zones) > 1
            error_message = "You must use more than one AZ for high availability"
        }
    }   

    # Static tag for all instances in the ASG
    # tag {
    #     key = "Name"
    #     value = "${var.cluster_name}-asg"
    #     propagate_at_launch = true
    # }

    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 50 # Keep 50% minimum instances healthy during refresh
            instance_warmup = 30 # Wait 30 seconds after launching new instance
        }
        triggers = ["tag"] # Explicitly trigger on tag changes  }
    }

    # Static refresh tag
    tag {
        key                 = "terraform_refresh"
        value              = timestamp()  # Forces update on every apply
        propagate_at_launch = true
    }

    # Dynamic tag for all instances in the AS
    dynamic "tag" {
        for_each = var.custom_tags
        content {
            key = tag.key
            value = tag.value
            propagate_at_launch = true 
        }
    }
    }

# autoscaling_schedule
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    # You can set value to either true or false in different environments.
    count = var.enable_autoscaling ? 1 : 0  

    scheduled_action_name = "scale-out-during-business-hours"
    min_size = 2
    max_size = 10
    desired_capacity = 10
    recurrence = "0 9 * * *"
    autoscaling_group_name = aws_autoscaling_group.example.name
}

# instance_security_group, not for the ALB
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0

  alarm_name  = "${var.cluster_name}-low-cpu-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}

# data "aws_ec2_instance_type" "instance" {
#   instance_type = var.instance_type
# }

locals {
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}