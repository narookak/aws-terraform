# bastion server
data "template_file" "bastion_user_data" {
  template = "${file("bastion_user_data.sh")}"

 vars {

  cidr_block = "${var.cidr_block}"
  db_user = "${var.db_user}"
  db_pass = "${random_string.password.result}"
  db_name = "${var.db_name}"
  db_host = "${aws_db_instance.mysql-db.address}"
  
 }
}
resource "aws_key_pair" "bastion_keypair" {
  public_key = "${file(var.public_keypair_path)}"
  key_name = "web_app_kp"
}
resource "aws_instance" "bastion" {
  ami = "${var.bastion_ami}"
  # The public SG is added for SSH and ICMP
  vpc_security_group_ids = ["${aws_security_group.pub.id}","${aws_security_group.web-sec.id}", "${aws_security_group.allow-nat.id}", "${aws_security_group.allout.id}", "${aws_security_group.allow-nat.id}"]
  instance_type = "${var.bastion_instance_type}"
  key_name = "${aws_key_pair.bastion_keypair.key_name}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  source_dest_check = "false"
  tags {
    Name = "Bastion Host"
  }
   user_data = "${data.template_file.bastion_user_data.rendered}"
}

resource "aws_eip" "bastion_eip" {
  depends_on = ["aws_internet_gateway.app_igw"]
  tags {
    Name = "Bastion Host"
  }
}

resource "aws_eip_association" "myapp_eip_assoc" {
  instance_id = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.myrex_vpc.id}"
  tags {
      Name = "Private"
  }
  route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.bastion.id}"
  }
}