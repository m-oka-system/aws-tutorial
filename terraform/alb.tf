resource "aws_lb" "alb" {
  name                       = "${var.alb_name}"
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.web-sg.id}"]
  subnets                    = ["${aws_subnet.public.0.id}", "${aws_subnet.public.1.id}"]
  internal                   = false
  enable_deletion_protection = false

  tags {
    Name = "${var.alb_name}"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web-tg.arn}"
  }
}

resource "aws_lb_target_group" "web-tg" {
  name                 = "${var.alb_name}-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${aws_vpc.vpc.id}"
  deregistration_delay = 300
  target_type          = "instance"

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    interval            = 30
    matcher             = 200
  }
}

resource "aws_lb_target_group_attachment" "tga" {
  # count            = "${length(var.zones)}"
  target_group_arn = "${aws_lb_target_group.web-tg.arn}"
  # target_id        = "${element(aws_instance.web-server.*.id, count.index)}"
  target_id        = "${aws_instance.web-server.id}"
  port             = 80
}

