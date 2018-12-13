#Provision vpc, subnets, igw, and default route-table
#1 VPC - 3 subnets (public, web, database)

#provision app vpc
resource "aws_vpc" "myrex_vpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "myEX"
  }
}

# create igw
resource "aws_internet_gateway" "app_igw" {
  vpc_id = "${aws_vpc.myrex_vpc.id}"
}

# add dhcp options
resource "aws_vpc_dhcp_options" "dhcp_scope_options" {
 domain_name_servers = ["AmazonProvidedDNS"]
}

# associate dhcp with vpc
resource "aws_vpc_dhcp_options_association" "dhcp_scope_options" {
  vpc_id          = "${aws_vpc.myrex_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_scope_options.id}"
}

#provision subnets
resource "aws_subnet" "public_subnet" {
  count = "${length(var.public_subnet)}"

  vpc_id = "${aws_vpc.myrex_vpc.id}"
  cidr_block = "${var.public_subnet[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"
  depends_on = ["aws_vpc_dhcp_options_association.dhcp_scope_options"]
  tags {
      Name = "public-myrex"
      Type = "Public"
  }
}
resource "aws_subnet" "public_web_subnet" {
  count = "${length(var.public_web_subnet)}"

  vpc_id = "${aws_vpc.myrex_vpc.id}"
  cidr_block = "${var.public_web_subnet[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"
  depends_on = ["aws_vpc_dhcp_options_association.dhcp_scope_options"]
  tags {
      Name = "web-myrex"
      Type = "Public"
  }
}
resource "aws_subnet" "private_app_subnet" {
  count = "${length(var.private_app_subnet)}"

  vpc_id = "${aws_vpc.myrex_vpc.id}"
  cidr_block = "${var.private_app_subnet[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"
  depends_on = ["aws_vpc_dhcp_options_association.dhcp_scope_options"]
  tags {
      Name = "app-myrex"
      Type = "Private"
  }
}
resource "aws_subnet" "private_db_subnet" {
  count = "${length(var.private_db_subnet)}"

  vpc_id = "${aws_vpc.myrex_vpc.id}"
  cidr_block = "${var.private_db_subnet[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"
  depends_on = ["aws_vpc_dhcp_options_association.dhcp_scope_options"]
  tags {
      Name = "db-myrex"
      Type = "Database"
  }
}
#default route table 
resource "aws_default_route_table" "default" {
   default_route_table_id = "${aws_vpc.myrex_vpc.default_route_table_id}"

   route {
       cidr_block = "0.0.0.0/0"
       gateway_id = "${aws_internet_gateway.app_igw.id}"
   }
}
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnet)}"

  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_default_route_table.default.id}"
}
resource "aws_route_table_association" "public-web" {
  count = "${length(var.public_web_subnet)}"

  subnet_id      = "${element(aws_subnet.public_web_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-app" {
  count = "${length(var.private_app_subnet)}"

  subnet_id      = "${element(aws_subnet.private_app_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}