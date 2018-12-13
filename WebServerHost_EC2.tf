#######################
# User data
#######################
data "template_file" "web_user_data" {
  template = "${file("web_user_data.sh")}"

 vars {
  webuser_name = "${var.webuser_name}"
  domain_name = "${var.domain_name}"
  aws_region = "${var.aws_region}"
  db_name = "${var.db_name}"
  db_user = "${var.db_user}"
  db_pass = "${random_string.password.result}"
  db_host = "${aws_db_instance.mysql-db.address}"
 }
}
# Keypair
resource "aws_key_pair" "web_keypair" {
  public_key = "${file(var.public_keypair_path)}"
  key_name = "my_public_key"
}
#######################
# Launch configuration
#######################
resource "aws_launch_configuration" "web_lc" {
  count = "${var.create_lc}"

  name_prefix                 = "${coalesce(var.web_lc_name, var.web_name)}-"
  image_id                    = "${var.web_ami}"
  instance_type               = "${var.web_instance_type}"
  #iam_instance_profile       = "${var.iam_instance_profile}"
  key_name                    = "${aws_key_pair.web_keypair.key_name}"
  security_groups             = ["${aws_security_group.web-sec.id}", "${aws_security_group.allout.id}","${aws_security_group.allow-nat.id}"]
  user_data                   = "${data.template_file.web_user_data.rendered}"
  enable_monitoring           = "${var.web_enable_monitoring}"
  ebs_optimized               = "${var.web_ebs_optimized}"
  lifecycle {
    create_before_destroy = true
  }
}

####################
# Autoscaling group
####################
resource "aws_autoscaling_group" "web_asg" {
  count = "${var.create_asg}"

  name_prefix          = "${join("-", compact(list(coalesce(var.web_asg_name, var.web_name), var.recreate_asg_when_lc_changes ? element(concat(random_pet.web_asg_name.*.id, list("")), 0) : "")))}-"
  launch_configuration = "${var.create_lc ? element(concat(aws_launch_configuration.web_lc.*.name, list("")), 0) : var.web_launch_configuration}"
  vpc_zone_identifier  = ["${aws_subnet.public_web_subnet.*.id}"]
  max_size             = "${var.web_max_size}"
  min_size             = "${var.web_min_size}"
  desired_capacity     = "${var.web_desired_capacity}"

  load_balancers            = ["${var.web_load_balancers}"]
  health_check_grace_period = "${var.web_health_check_grace_period}"
  health_check_type         = "${var.web_health_check_type}"

  min_elb_capacity          = "${var.web_min_elb_capacity}"
  wait_for_elb_capacity     = "${var.web_wait_for_elb_capacity}"
  target_group_arns         = ["${aws_lb_target_group.web_tg.arn}"]
  default_cooldown          = "${var.web_default_cooldown}"
  force_delete              = "${var.web_force_delete}"
  termination_policies      = "${var.web_termination_policies}"
  suspended_processes       = "${var.web_suspended_processes}"
  placement_group           = "${var.web_placement_group}"
  enabled_metrics           = ["${var.web_enabled_metrics}"]
  metrics_granularity       = "${var.web_metrics_granularity}"
  wait_for_capacity_timeout = "${var.web_wait_for_capacity_timeout}"
  protect_from_scale_in     = "${var.web_protect_from_scale_in}"

  tags = ["${concat(
      list(map("key", "Name", "value", var.web_name, "propagate_at_launch", true)),
      var.web_tags,
      local.tags_asg_format
   )}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "web_asg_name" {
  count = "${var.recreate_asg_when_lc_changes ? 1 : 0}"

  separator = "-"
  length    = 2

  keepers = {
    # Generate a new pet name each time we switch launch configuration
    lc_name = "${var.create_lc ? element(concat(aws_launch_configuration.web_lc.*.name, list("")), 0) : var.web_launch_configuration}"
  }
}