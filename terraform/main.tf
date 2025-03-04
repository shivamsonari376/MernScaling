provider "aws" {
  region = var.region
}

# Create a Target Group for Backend
resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-target-group3002"
  port     = 3002
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Create an ALB
resource "aws_lb" "my_alb" {
  name               = "my-application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group]
  subnets           = [var.subnet_id]

  enable_deletion_protection = false
}

# Create ALB Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Create an Auto Scaling Group
resource "aws_launch_template" "backend_lt" {
  name_prefix   = "backend-instance-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group]
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  desired_capacity     = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = [var.subnet_id]

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.backend_tg.arn]
}

# Create a Standalone EC2 Instance for Frontend
resource "aws_instance" "frontend_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group]
  associate_public_ip_address = true

  tags = {
    Name = "Frontend-Server"
  }
}
