# defines output values from a root module.
# module.<module_name>.<output_name>

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "alb_dns_name" {
  # This references the output variable alb_dns_name from a module named alb.
  value       = module.alb.alb_dns_name
  description = "The domain name of the load balancer"
}

output "asg_name" {
  value       = module.asg.asg_name
  description = "The name of the Auto Scaling Group"
}

output "instance_security_group_id" {
  value       = module.asg.instance_security_group_id
  description = "The ID of the EC2 Instance Security Group"
}

# Additional useful outputs
output "alb_zone_id" {
  value       = module.alb.alb_zone_id
  description = "The zone ID of the load balancer"
}

