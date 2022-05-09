output "lb_target_group_arn" {
    value = aws_lb_target_group.target_group.arn
    description = "The ARN for the target group for the created Load Balancer"
}
output "lb_domain_name" {
    value = aws_lb.load_balancer.dns_name
    description = "The domain name for the created Load Balancer"
}