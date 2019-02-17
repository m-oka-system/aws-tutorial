################################
# VPC
################################
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_prefix}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.vpc_name}"
  }
}

################################
# Subnet
################################
resource "aws_subnet" "public" {
  count                   = "${length(var.zones)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_prefix, 8, 11 + count.index)}" #10.0.11.0/24
  map_public_ip_on_launch = true
  availability_zone       = "${element(var.zones, count.index)}"

  tags {
    Name = "${var.vpc_name}-public-${substr(element(var.zones, count.index),-2,2)}"
  }
}

resource "aws_subnet" "private" {
  count             = "${length(var.zones)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.vpc_prefix, 8, 21 + count.index)}" # 10.0.21.0/24, 10.0.22.0/24
  availability_zone = "${element(var.zones, count.index)}"

  tags {
    Name = "${var.vpc_name}-private-${substr(element(var.zones, count.index),-2,2)}"
  }
}

################################
# Gateway
################################
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.vpc_name}-igw"
  }
}

################################
# PublicTable
################################
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public-subnet-rta" {
  count          = "${length(var.zones)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}


################################
# PrivateTable
################################
resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = "${aws_nat_gateway.natgw.id}"
  # }

  tags {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route_table_association" "private-subnet-rta" {
  count          = "${length(var.zones)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

################################
# Security Group EC2
################################
resource "aws_security_group" "web-sg" {
  name   = "ssh-http-full-open"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "web-sg"
  }
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = "${aws_security_group.web-sg.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http" {
  security_group_id = "${aws_security_group.web-sg.id}"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all" {
  security_group_id = "${aws_security_group.web-sg.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

################################
# Security Group RDS
################################
resource "aws_security_group" "db-sg" {
  name   = "db-open"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "db-sg"
  }
}

resource "aws_security_group_rule" "mysql" {
  security_group_id        = "${aws_security_group.db-sg.id}"
  source_security_group_id = "${aws_security_group.web-sg.id}"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
}
