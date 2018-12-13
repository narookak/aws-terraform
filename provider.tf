#Define API Endpoints for Stratoscale Symphony

provider "aws" {
  shared_credentials_file = "${var.aws_credentials_file}"
  region = "${var.aws_region}"
}