#######################
# User data
#######################
data "template_file" "app_user_data" {
  template = "${file("app_user_data.sh")}"

 vars {
  appuser_name = "${var.appuser_name}"
  domain_name = "${var.domain_name}"
  aws_region = "${var.aws_region}"
  db_name = "${var.db_name}"
  db_user = "${var.db_user}"
  db_pass = "${random_string.password.result}"
  db_host = "${aws_db_instance.mysql-db.address}"
 }
}
# Keypair
resource "aws_key_pair" "app_keypair" {
  public_key = "${file(var.public_keypair_path)}"
  key_name = "app_public_key"
}
#######################
# Launch configuration
#######################
resource "aws_launch_configuration" "app_lc" {
  count = "${var.create_lc}"

  name_prefix                 = "${coalesce(var.app_lc_name, var.app_name)}-"
  image_id                    = "${var.app_ami}"
  instance_type               = "${var.app_instance_type}"
  #iam_instance_profile       = "${var.iam_instance_profile}"
  key_name                    = "${aws_key_pair.app_keypair.key_name}"
  security_groups             = ["${aws_security_group.web-sec.id}", "${aws_security_group.allout.id}","${aws_security_group.allow-nat.id}"]
  user_data                   = "${data.template_file.app_user_data.rendered}"
  enable_monitoring           = "${var.app_enable_monitoring}"
  ebs_optimized               = "${var.app_ebs_optimized}"
  lifecycle {
    create_before_destroy = true
  }
}

####################
# Autoscaling group
####################
resource "aws_autoscaling_group" "app_asg" {
  count = "${var.create_asg}"

  name_prefix          = "${join("-", compact(list(coalesce(var.app_asg_name, var.app_name), var.recreate_asg_when_lc_changes ? element(concat(random_pet.app_asg_name.*.id, list("")), 0) : "")))}-"
  launch_configuration = "${var.create_lc ? element(concat(aws_launch_configuration.app_lc.*.name, list("")), 0) : var.app_launch_configuration}"
  vpc_zone_identifier  = ["${aws_subnet.private_app_subnet.*.id}"]
  max_size             = "${var.app_max_size}"
  min_size             = "${var.app_min_size}"
  desired_capacity     = "${var.app_desired_capacity}"

  load_balancers            = ["${var.app_load_balancers}"]
  health_check_grace_period = "${var.app_health_check_grace_period}"
  health_check_type         = "${var.app_health_check_type}"

  min_elb_capacity          = "${var.app_min_elb_capacity}"
  wait_for_elb_capacity     = "${var.app_wait_for_elb_capacity}"
  target_group_arns         = ["${aws_lb_target_group.app_tg.arn}"]
  default_cooldown          = "${var.app_default_cooldown}"
  force_delete              = "${var.app_force_delete}"
  termination_policies      = "${var.app_termination_policies}"
  suspended_processes       = "${var.app_suspended_processes}"
  placement_group           = "${var.app_placement_group}"
  enabled_metrics           = ["${var.app_enabled_metrics}"]
  metrics_granularity       = "${var.app_metrics_granularity}"
  wait_for_capacity_timeout = "${var.app_wait_for_capacity_timeout}"
  protect_from_scale_in     = "${var.app_protect_from_scale_in}"

  tags = ["${concat(
      list(map("key", "Name", "value", var.app_name, "propagate_at_launch", true)),
      var.app_tags,
      local.app_tags_asg_format
   )}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "app_asg_name" {
  count = "${var.recreate_asg_when_lc_changes ? 1 : 0}"

  separator = "-"
  length    = 2

  keepers = {
    # Generate a new pet name each time we switch launch configuration
    lc_name = "${var.create_lc ? element(concat(aws_launch_configuration.app_lc.*.name, list("")), 0) : var.app_launch_configuration}"
  }
}