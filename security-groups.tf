resource "aws_security_group" "db" {
  name = "db-secgroup"
  vpc_id = "${aws_vpc.myrex_vpc.id}"

  # ssh access from anywhere
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self = true
    
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "web-sec" {
  name = "webserver-secgroup"
  vpc_id = "${aws_vpc.myrex_vpc.id}"

  # Internal HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #ssh from anywhere (for debugging)
  ingress {
    from_port   = 7272
    to_port     = 7272
    protocol    = "tcp"
    self = true
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    self = true
  }
  
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "app-sec" {
  name = "appserver-secgroup"
  vpc_id = "${aws_vpc.myrex_vpc.id}"

  # Internal HTTP access from anywhere
  ingress {
    from_port   = 3000
    to_port     = 3002
    protocol    = "tcp"
    self = true
  }
  #ssh from anywhere (for debugging)
  ingress {
    from_port   = 7272
    to_port     = 7272
    protocol    = "tcp"
    self = true
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    self = true
  }
  
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#public access sg 
resource "aws_security_group" "pub" {
  name = "pub-secgroup"
  vpc_id = "${aws_vpc.myrex_vpc.id}"

  # ssh access from anywhere
  ingress {
    from_port   = 7272
    to_port     = 7272
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "allout" {
  name = "allout-secgroup"
  vpc_id = "${aws_vpc.myrex_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "allow-nat" {
  name = "allow-nat"
  vpc_id = "${aws_vpc.myrex_vpc.id}"

  # allow access from referred Security groups
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }
}
resource "aws_security_group" "AppLB-sec" {
  name = "applb-secgroup"
  vpc_id = "${aws_vpc.myrex_vpc.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ping from anywhere
    ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "WebLB-sec" {
  name = "weblb-secgroup"
  vpc_id = "${aws_vpc.myrex_vpc.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ping from anywhere
    ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}