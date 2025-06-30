terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_lb" "example" {
    name = var.alb_name
    load_balancer_type = "application"
    subnets = var.subnet_ids
    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = local.http_port
    protocol = "HTTP"
    
    # By default, return a simple 404 page
    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "404: Page not found"
            status_code = 404
        }
    }
}

resource "aws_security_group" "alb" {
    name = var.alb_name
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.alb.id
    
    from_port = local.http_port
    to_port = local.http_port
    protocol = local.tcp_protocol
    cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
    type = "egress"
    security_group_id = aws_security_group.alb.id

    from_port = local.any_port
    to_port = local.any_port
    protocol = local.any_protocol
    cidr_blocks = local.all_ips    
}

# resource "aws_lb_target_group" "asg" {
#     name = "${var.cluster_name}-asg"
#     port = var.server_port
#     protocol = "HTTP"
#     vpc_id = data.aws_vpc.default.id
    
#     health_check {
#         path = "/"
#         protocol = "HTTP"
#         matcher = "200"
#         interval = 15
#         timeout = 3
#         healthy_threshold = 2
#         unhealthy_threshold = 2
#     }
# }

# resource "aws_lb_listener_rule" "asg" {
#     listener_arn = aws_lb_listener.http.arn
#     priority = 100

#     condition {
#         path_pattern {
#             values = ["*"]
#         }
#     }

#     action {
#         type = "forward"
#         target_group_arn = aws_lb_target_group.asg.arn
#     }
# }

# resource "null_resource" "test_deployment" {
#   provisioner "local-exec" {
#     command = <<EOT
#       echo "Testing connection to ${aws_lb.example.dns_name}..."
      
#       # Add a sleep to allow the ALB and instances to initialize
#       echo "Waiting for 60 seconds for ALB to become ready..."
#       sleep 60
      
#       # Try to curl the ALB DNS name with a longer timeout
#       curl -m 15 http://${aws_lb.example.dns_name}

#       # Check the curl exit status
#       if [ $? -eq 0 ]; then
#          echo -e "\nSuccess: Server is responding"
#       else
#          echo -e "\nError: Server is not responding"
#          exit 1
#       fi  
#     EOT
#     interpreter = ["bash", "-c"]
#   }
  
#   # Make sure to depend on both the ALB and ASG
#   depends_on = [
#     aws_lb.example,
#     aws_autoscaling_group.example,
#     aws_lb_listener.http,
#     aws_lb_listener_rule.asg
#   ]
# }
