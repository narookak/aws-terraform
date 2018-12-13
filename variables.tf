#
#-------------------------------------------------
# Launch Congis
variable "create_lc" {
  description = "Whether to create launch configuration"
  default     = true
}

variable "create_asg" {
  description = "Whether to create autoscaling group"
  default     = true
}

variable "recreate_asg_when_lc_changes" {
  description = "Whether to recreate an autoscaling group when launch configuration changes"
  default     = true
}

#variable "secret_key" {
#     description = "AWS Secrect Key"
#}
#variable "access_key" {
#     description = "AWS Access ID"
#}
variable "aws_credentials_file"{
        description = "Specify the path to AWS credentials file"
}
variable "bastion_ami" {
     description = "AMI to be used to launch the bastion host"
}

variable "bastion_instance_type" {
     description = "Instance Type to be launched for bastion server"
}

variable "public_keypair_path" {
     description = "Path to public keypair to be assigned on EC2 instances"
}

variable "aws_region" {
}
variable "domain_name" {
        description = "domain name"
}

variable "availability_zones" {
     description = "AZs in this region to use"
     type = "list"
}
variable "cidr_block" {
  description = "CIDR Block for VPC"
  
}
variable "public_subnet" {
    type = "list"
}
variable "public_web_subnet" {
    type = "list"
}
variable "private_app_subnet" {
    type = "list"
}
variable "private_db_subnet" {
    type = "list"
}
variable "certificate_arn" {
  description = "ARN of certificate from Amazon Certificate Manager"
}
variable "ssl_policy" {
  description = "SSL Policy for Load Balancer Listener"
}

