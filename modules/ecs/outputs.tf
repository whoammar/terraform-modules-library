output "alb_dns" {
  value = try(aws_lb.this[0].dns_name, null)
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}