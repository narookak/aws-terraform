
### AWS Account
aws_credentials_file = "../aws/credentials"

# Use Latest version of Amazon Linux2 Public AMI
web_ami = "ami-00035f41c82244dab"
app_ami = "ami-00035f41c82244dab"
bastion_ami = "ami-00035f41c82244dab"

web_instance_type = "t3.micro"
app_instance_type = "t3.micro"
bastion_instance_type = "t3.micro"
db_instance_type = "db.t2.medium"
public_keypair_path = "./my_public_key.pem"

# Database Information
db_user = "myex_dbadm"
db_name = "myex_mydb"
rds_identifier = "mysql-rds-prod"
domain_name = "khushal.com"
appuser_name = "myex-app"
webuser_name = "myex-web"

# Region
aws_region = "eu-west-1"
# Availability Zones
availability_zones = [ "eu-west-1a", "eu-west-1b", "eu-west-1c" ]

cidr_block = "192.168.0.0/16"
public_subnet = [ "192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24" ]
public_web_subnet = [ "192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24"]
private_app_subnet = [ "192.168.21.0/24", "192.168.22.0/24", "192.168.23.0/24" ]
private_db_subnet= [ "192.168.31.0/24", "192.168.32.0/24", "192.168.33.0/24" ]

#Launch Config & ASG details for Web and App instance
app_lc_name = "lc-apps-prod"
app_asg_name = "asg-apps-prod"
app_name = "myappnode"
app_alb-tg_name = "tg-app-prod"

web_lc_name = "lc-web-prod"
web_asg_name = "asg-web-prod"
web_alb_name = "alb-web-prod"
web_alb-tg_name = "tg-web-prod"
web_name = "mywebapp"

#TLS/SSL information for ALB
certificate_arn   = "arn:aws:acm:eu-west-1:209211465600:certificate/aca6ee1d-1207-440b-ba56-a32afffe2485"
ssl_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"