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
    user_data = "${file("infra/go-server-install.sh")}"
    tags {
        Name = "GoCD Server"
    }
}

resource "aws_eip_association" "GoCD-Server-EIP" {
    instance_id = "${aws_instance.GoCD-Server.id}"
    allocation_id = "${aws_eip.GoCD-Server-IP.id}"
}

data "template_file" "go-agent-init" {
  template = "${file("infra/go-agent-install.sh.tpl")}"

  vars {
    go-server-address = "${aws_eip.GoCD-Server-IP.public_dns}"
  }
}

resource "aws_instance" "GoCD-Agent" {
    ami = "ami-0cc96feef8c6bbff3"
    instance_type = "t2.micro"

    vpc_security_group_ids = ["${aws_security_group.GoCD-SG.id}"]
    key_name = "aws-whelan-personal"

    user_data = "${data.template_file.go-agent-init.rendered}"

    tags {
        Name = "GoCD Agent"
    }
}

resource "aws_instance" "Frontend-Docker" {
    ami = "ami-0cc96feef8c6bbff3"
    instance_type = "t2.micro"

    vpc_security_group_ids = ["${aws_security_group.GoCD-SG.id}"]
    key_name = "aws-whelan-personal"

    user_data = "${file("infra/frontend-server-install.sh")}"

    tags {
        Name = "Frontend Host"
    }
}
