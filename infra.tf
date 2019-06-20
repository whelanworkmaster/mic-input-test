provider "aws" {
    region = "us-east-1"
}

resource "aws_eip" "GoCD-Server-IP" {
  vpc = true
}

resource "aws_security_group" "GoCD-SG" {
    name = "GoCD SG"

    ingress {
        from_port = 8154
        to_port = 8154
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "GoCD-Server" {
    ami = "ami-0cc96feef8c6bbff3"
    instance_type = "t2.micro"

    vpc_security_group_ids = ["${aws_security_group.GoCD-SG.id}"]
    key_name = "aws-whelan-personal"

    user_data = <<-EOF
              #!/bin/bash
              sudo mkdir home/downloads
              cd home/downloads
              sudo yum install -y java-1.8.0-openjdk
              wget https://download.gocd.org/binaries/19.5.0-9272/rpm/go-server-19.5.0-9272.noarch.rpm
              sudo rpm -i go-server-19.5.0-9272.noarch.rpm
              /etc/init.d/go-server start
              EOF

    tags {
        Name = "GoCD Server"
    }
}

resource "aws_eip_association" "GoCD-Server-EIP" {
    instance_id = "${aws_instance.GoCD-Server.id}"
    allocation_id = "${aws_eip.GoCD-Server-IP.id}"
}

resource "aws_instance" "GoCD-Agent" {
    ami = "ami-0cc96feef8c6bbff3"
    instance_type = "t2.micro"

    vpc_security_group_ids = ["${aws_security_group.GoCD-SG.id}"]
    key_name = "aws-whelan-personal"

    user_data = <<-EOF
              #!/bin/bash
              sudo mkdir home/downloads
              cd home/downloads
              sudo yum install -y java-1.8.0-openjdk
              wget https://download.gocd.org/binaries/19.5.0-9272/rpm/go-agent-19.5.0-9272.noarch.rpm
              sudo rpm -i go-agent-19.5.0-9272.noarch.rpm
              sudo sed -i 's|127.0.0.1|${aws_eip.GoCD-Server-IP.public_dns}|g' /etc/default/go-agent
              sudo /etc/init.d/go-agent start
              EOF

    tags {
        Name = "GoCD Agent"
    }
}

