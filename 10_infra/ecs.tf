# ---------------------------------------------
# Elastic Container Service - Cluster
# ---------------------------------------------
resource "aws_ecs_cluster" "webapp" {
  name = "${var.project}-${var.environment}-webapp-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name    = "${var.project}-${var.environment}-webapp-cluster"
    Project = var.project
    Env     = var.environment
  }
}

# ---------------------------------------------
# Elastic Container Service - Service
# ---------------------------------------------
resource "aws_ecs_service" "webapp" {
  name = "${var.project}-${var.environment}-webapp-service"

  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.webapp.id
  task_definition = aws_ecs_task_definition.webapp.arn
  desired_count   = 1
  # depends_on      = [aws_iam_role.ecs_task_exec_iam_role]

  network_configuration {
    subnets = [aws_subnet.public_subnet_1a.id]
    security_groups = [
      aws_security_group.app_sg.id,
      aws_security_group.opmng_sg.id,
    ]
    assign_public_ip = true
  }

  health_check_grace_period_seconds = 300

  load_balancer {
    target_group_arn = aws_lb_target_group.webapp_blue.arn
    container_name   = "webapp"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }
}

# ---------------------------------------------
# CloudWatch Logs Group
# ---------------------------------------------
resource "aws_cloudwatch_log_group" "webapp" {
  name              = "/ecs/tastylog-dev-webapp-template"
  retention_in_days = 14

  tags = {
    Name    = "${var.project}-${var.environment}-webapp-logs"
    Project = var.project
    Env     = var.environment
  }
}

# ---------------------------------------------
# Elastic Container Service - Task
# ---------------------------------------------
resource "aws_ecs_task_definition" "webapp" {
  family = "${var.project}-${var.environment}-webapp-template"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256 # .25 vCPU
  memory                   = 512 # 512 MB

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  execution_role_arn = "arn:aws:iam::229586729911:role/tastylog-dev-ecs-task-exec-iam-role"

  container_definitions = jsonencode([
    {
      name      = "webapp"
      image     = "${aws_ecr_repository.webapp.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "MYSQL_HOST"
          value = "tastylog-dev-mysql-standalone.cvgqpzgylaz0.ap-northeast-1.rds.amazonaws.com"
        },
        {
          name  = "MYSQL_PORT"
          value = "3306"
        },
        {
          name  = "MYSQL_DATABASE"
          value = "tastylog"
        },
        {
          name  = "MYSQL_USERNAME"
          value = "admin"
        },
        {
          name  = "MYSQL_PASSWORD"
          value = "password"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/tastylog-dev-webapp-template"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])


  # volume {
  #   name      = "service-storage"
  #   host_path = "/ecs/service-storage"
  # }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }

  tags = {
    Name    = "${var.project}-${var.environment}-webapp-template"
    Project = var.project
    Env     = var.environment
  }
}
