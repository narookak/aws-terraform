### Terraform two tier app deployment (LEMP)

## Description:
This Terraform script will deploy a single region highly available web site with RDS, EC2 and VPC AWS. 

## Before running
Along with your API credentials, ensure you specify the AMI ID in your .tfvars file.

### Networks to be provisioned:
- 1 VPC 
- 1 Internet Gateway
- 3 Database subnets 
- 3 Web subnets 
- 3 App subnets 
- 3 Public subnets 
- 1 Bastion host + NAT Instance

### Resources:
- 1 Web servers (or more) (Ubuntu Linux2)
- 1 App servers (or more) (Ubuntu Linux2)
- 1 RDS instance (MySQL 5.7)


