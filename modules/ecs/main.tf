# =========================
# ECS CLUSTER
# =========================
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

# =========================
# LOG GROUPS
# =========================
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.services

  name              = "/ecs/${each.key}"
  retention_in_days = var.log_retention_days
}

# =========================
# IAM ROLES
# =========================
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.cluster_name}-exec"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "exec" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${var.cluster_name}-task"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# =========================
# TASK DEFINITIONS
# =========================
resource "aws_ecs_task_definition" "this" {
  for_each = var.services

  family                   = each.key
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = each.value.cpu
  memory = each.value.memory

  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name  = each.key
      image = each.value.image

      essential = true

      portMappings = [
        {
          containerPort = each.value.port
        }
      ]

      environment = [
        for k, v in each.value.environment : {
          name  = k
          value = v
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this[each.key].name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# =========================
# ALB
# =========================
resource "aws_lb" "this" {
  count = var.enable_alb ? 1 : 0

  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = var.alb_security_groups
}

# =========================
# TARGET GROUPS
# =========================
resource "aws_lb_target_group" "this" {
  for_each = var.enable_alb ? var.services : {}

  name        = "${each.key}-tg"
  port        = each.value.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = lookup(each.value, "health_check_path", "/")
  }
}

# =========================
# LISTENER
# =========================
resource "aws_lb_listener" "this" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = 80

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = 200
      content_type = "text/plain"
      message_body = "OK"
    }
  }
}

# =========================
# LISTENER RULES
# /api* → api service (with URL rewrite: strips /api prefix)
# /*    → frontend service
# =========================
resource "aws_lb_listener_rule" "this" {
  for_each = var.enable_alb ? var.services : {}

  listener_arn = aws_lb_listener.this[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path
    }
  }

  # Only apply URL rewrite for the api service
  # Strips /api prefix before forwarding: /api/users → /users
  dynamic "transform" {
    for_each = each.key == "api" ? [1] : []
    content {
      type = "url-rewrite"
      url_rewrite_config {
        rewrite {
          regex   = "^/api/?(.*)"
          replace = "/$1"
        }
      }
    }
  }
}

# =========================
# ECS SERVICES
# =========================
resource "aws_ecs_service" "this" {
  for_each = var.services

  name            = each.key
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.key].arn

  desired_count = each.value.desired_count
  launch_type   = "FARGATE"

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = var.ecs_security_groups
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.enable_alb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this[each.key].arn
      container_name   = each.key
      container_port   = each.value.port
    }
  }

  depends_on = [aws_lb_listener_rule.this]
}

# =========================
# AUTOSCALING
# =========================
resource "aws_appautoscaling_target" "this" {
  for_each = var.enable_autoscaling ? var.services : {}

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  resource_id = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this[each.key].name}"

  min_capacity = var.autoscaling.min
  max_capacity = var.autoscaling.max
}

resource "aws_appautoscaling_policy" "cpu" {
  for_each = var.enable_autoscaling ? var.services : {}

  name               = "${each.key}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.this[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.autoscaling.cpu
  }
}