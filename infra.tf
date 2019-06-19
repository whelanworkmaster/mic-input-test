provider "aws" {
    region = "us-east-1"
}

variable "gocd_server_port" {
    description = "The port the GoCD Server will use for HTTP requests"
    default = 8154
}

resource "aws_eip" "GoCD-Server-IP" {
  vpc = true
}

resource "aws_security_group" "GoCD-Server" {
    name = "GoCD Server SG"

    ingress {
        from_port = "${var.gocd_server_port}"
        to_port = "${var.gocd_server_port}"
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

    vpc_security_group_ids = ["${aws_security_group.GoCD-Server.id}"]
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
