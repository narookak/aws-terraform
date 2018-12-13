# Create db instance 

#make db subnet group 
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "main"
  subnet_ids = ["${aws_subnet.private_db_subnet.*.id}"]
}
resource "random_string" "password" {
  length = 18 
  upper = true
  lower = true
  number = true
  special = false
}

#provision the database
resource "aws_db_instance" "mysql-db" {
  identifier = "mysql-db"
  instance_class = "${var.db_instance_type}"
  allocated_storage = 100
  engine = "mysql"
  engine_version = "5.7.23"
  name = "${var.db_name}"
  password = "${random_string.password.result}"
  username = "${var.db_user}"
  skip_final_snapshot = true
  copy_tags_to_snapshot = true
  db_subnet_group_name = "${aws_db_subnet_group.dbsubnet.name}"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  auto_minor_version_upgrade = true
  backup_retention_period = 7
  backup_window = "20:00-23:59"
  maintenance_window = "Sun:00:00-Sun:03:00"
  apply_immediately = true
  tags {
    Name = "mysql-db"
  }
  
}

