resource "aws_db_subnet_group" "db-subnet" {
  name       = "${var.db_instance_name}-subnet-gp"
  subnet_ids = ["${aws_subnet.private.0.id}", "${aws_subnet.private.1.id}"]

  tags {
    Name = "${var.db_instance_name}-subnet-gp"
  }
}

resource "aws_db_parameter_group" "db-pg" {
  name   = "${var.db_instance_name}-pg"
  family = "mysql5.7"

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}

resource "aws_db_instance" "db" {
  # instance parameters
  identifier     = "${var.db_instance_name}"
  instance_class = "db.t2.micro"
  # If muti_az = false, availability_zone must be specified.
  multi_az               = false
  # multi_az                = true
  availability_zone      = "ap-northeast-1a"
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = "${aws_db_subnet_group.db-subnet.name}"
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]

  # storage parameters
  storage_type      = "gp2"
  allocated_storage = 20

  # engine parameters
  engine         = "mysql"
  engine_version = "5.7.23"
  port           = "3306"
  # name           = "${var.database_name}"
  username       = "${var.sql_login}"
  password       = "${var.sql_password}"

  # backup and maintenance parameters
  backup_retention_period     = 1
  backup_window               = "19:00-20:00"
  maintenance_window          = "Sat:20:00-Sat:21:00"
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = false
}
