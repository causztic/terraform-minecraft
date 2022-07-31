resource "aws_lb" "minecraft" {
  subnets = [aws_subnet.public.id]
  security_groups = [aws_security_group.minecraft.id]
}

resource "aws_lb_target_group" "minecraft" {
  # health_check
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  port        = "25565"
  protocol    = "TCP"
}

resource "aws_lb_target_group" "rcon" {
  # health_check
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  port        = "25575"
  protocol    = "TCP"
}

resource "aws_lb_listener" "minecraft" {
  load_balancer_arn = aws_lb.minecraft.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.minecraft.arn
  }
}

resource "aws_lb_listener" "rcon" {
  load_balancer_arn = aws_lb.minecraft.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rcon.arn
  }
}

resource "aws_lb_target_group_attachment" "minecraft" {
  target_group_arn = aws_lb_target_group.minecraft.arn
  target_id        = aws_ecs_service.minecraft.id
  port             = 25565
}