resource "aws_instance" "web-server" {
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "t2.micro"
  key_name                    = "${var.key_pair}"
  subnet_id                   = "${aws_subnet.public.id}"
  vpc_security_group_ids      = ["${aws_security_group.web-sg.id}"]
  associate_public_ip_address = true

  user_data = <<EOF
    #!/bin/bash

    # ホスト名
    sed -i "s/^HOSTNAME=[a-zA-Z0-9\.\-]*$/HOSTNAME=web-1/g" /etc/sysconfig/network
    hostname "web-1"

    # タイムゾーン
    cp /usr/share/zoneinfo/Japan /etc/vartime
    sed -i 's|^ZONE=[a-zA-Z0-9\.\-\"]*$|ZONE="Asia/Tokyo”|g' /etc/sysconfig/clock

    # 言語設定
    echo "LANG=ja_JP.UTF-8" > /etc/sysconfig/i18n

    # 必要なパッケージの導入
    yum update -y
    sudo yum install -y mysql
    sudo yum install -y git
  EOF

  tags {
    Name = "web-1"
  }
}

resource "aws_eip" "web-eip" {
  instance = "${aws_instance.web-server.id}"
  vpc      = true
}