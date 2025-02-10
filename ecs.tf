provider "aws" {
  region = "us-east-1" # Change as needed
}

# VPC
resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "ecs_subnet" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}

# IAM Role for ECS - Use existing role if it exists
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRoledashath"
}

resource "aws_iam_policy_attachment" "ecs_task_execution_role_policy" {
  name       = "ecs-task-execution-policy"
  roles      = [data.aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "my-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "my-container",
      image = "nginx:latest",
      memory = 512,
      cpu    = 256,
      essential = true,
      portMappings = [{
        containerPort = 80,
        hostPort      = 80
      }]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2
  launch_type     = "EC2"
}
