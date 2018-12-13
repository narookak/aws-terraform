variable "app_name" {
}
variable "app_lc_name" {
  description = "Creates a unique name for launch configuration beginning with the specified prefix"
  default     = ""
}
variable "app_asg_name" {
  description = "Creates a unique name for autoscaling group beginning with the specified prefix"
  default     = ""
}
variable "app_launch_configuration" {
  description = "The name of the launch configuration to use (if it is created outside of this module)"
  default     = ""
}
#############
### ASG
# Launch configuration

#variable "iam_instance_profile" {
# description = "The IAM instance profile to associate with launched instances"
#  default     = ""
#}
variable "app_enable_monitoring" {
  description = "Enables/disables detailed monitoring. This is enabled by default."
  default     = false
}
variable "app_ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}
# Autoscaling group
variable "app_max_size" {
  description = "The maximum size of the auto scale group"
  default = 2
}
variable "app_min_size" {
  description = "The minimum size of the auto scale group"
  default = 1
}
variable "app_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  default = 1
}
variable "app_default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  default     = 300
}
variable "app_health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  default     = 300
}
variable "app_health_check_type" {
  description = "Controls how health checking is done. Values are - EC2 and ELB"
  default = "ELB"
}
variable "app_force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling"
  default     = false
}
variable "app_load_balancers" {
  description = "A list of elastic load balancer names to add to the autoscaling group names"
  default     = []
}
variable "app_target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  default     = []
}
variable "app_termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default"
  type        = "list"
  default     = ["Default"]
}
variable "app_suspended_processes" {
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZRebalance, AlarmNotification, ScheduledActions, AddToLoadBalancer. Note that if you suspend either the Launch or Terminate process types, it can prevent your autoscaling group from functioning properly."
  default     = []
}
variable "app_tags" {
  description = "A list of tag blocks. Each element should have keys named key, value, and propagate_at_launch."
  default     = []
}
variable "app_tags_as_map" {
  description = "A map of tags and values in the same format as other resources accept. This will be converted into the non-standard format that the aws_autoscaling_group requires."
  type        = "map"
  default     = {}
}
variable "app_placement_group" {
  description = "The name of the placement group into which you'll launch your instances, if any"
  default     = ""
}
variable "app_metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute"
  default     = "1Minute"
}
variable "app_enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances"
  type        = "list"

  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}
variable "app_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  default     = "10m"
}
variable "app_min_elb_capacity" {
  description = "Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes"
  default     = 0
}
variable "app_wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over min_elb_capacity behavior."
  default     = false
}
variable "app_protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events."
  default     = false
}
variable "app_ami" {
     description = "AMI to be used to launch the instance"
}
variable "appuser_name" {
  description = "User for php and FTP"
}
variable "app_instance_type" {
}
variable "app_alb-tg_name" {
  description = "Name of ALB target group"
}
