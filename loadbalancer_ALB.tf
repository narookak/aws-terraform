#Provision load balancer
resource "aws_lb" "wlb" {
  subnets = ["${aws_subnet.public_subnet.*.id}"]
  internal = false
  security_groups = ["${aws_security_group.WebLB-sec.id}"]
  name = "${var.web_alb_name}"
}
output "wlb_eip" {
  value = "${aws_lb.wlb.dns_name}"
}
resource "aws_lb_target_group" "web_tg" {
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_vpc.myrex_vpc.id}"
  name = "${var.web_alb-tg_name}"
  health_check = 
    {
      protocol            = "HTTP"
      path                = "/elb-heartbeat.php"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 5
      timeout             = 20
    },

}
resource "aws_lb_target_group" "app_tg" {
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_vpc.myrex_vpc.id}"
  name = "${var.app_alb-tg_name}"
  health_check = 
    {
      protocol            = "HTTP"
      path                = "/elb-heartbeat.php"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 5
      timeout             = 20
    },

}
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = "${aws_lb.wlb.arn}"
  port = 80
  "default_action" {
    target_group_arn = "${aws_lb_target_group.web_tg.arn}"
    type = "forward"
  }
}

resource "aws_lb_listener" "web_listener_ssl" {
  load_balancer_arn = "${aws_lb.wlb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "${var.ssl_policy}"
  certificate_arn   = "${var.certificate_arn}"

  "default_action" {
    target_group_arn = "${aws_lb_target_group.web_tg.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener_rule" "app1_host_based_routing" {
  listener_arn = "${aws_lb_listener.web_listener.arn}"
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.app_tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["aws1.khushal.com"]
  }
}
resource "aws_lb_listener_rule" "app2_host_based_routing" {
  listener_arn = "${aws_lb_listener.web_listener.arn}"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.app_tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["aws2.khushal.com"]
  }
}
resource "aws_lb_listener_rule" "sslapp1_host_based_routing" {
  listener_arn = "${aws_lb_listener.web_listener_ssl.arn}"
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.app_tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["aws1.khushal.com"]
  }
}
resource "aws_lb_listener_rule" "sslapp2_host_based_routing" {
  listener_arn = "${aws_lb_listener.web_listener_ssl.arn}"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.app_tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["aws2.khushal.com"]
  }
}