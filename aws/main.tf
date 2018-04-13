provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_key_pair" "emr_key_pair" {
  key_name   = "emr-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "default" {
  name        = "sec_group_elb"
  description = "Security group for backend servers"

  # SSH access from anywhere
  ingress {
    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "build_install" {
  template = "${file("./scripts/build_install.sh")}"
  vars {
    git_repo = "${var.git_repo}"
  }
}

resource "aws_instance" "bitcoin-tf-small" {
  ami = "${var.ubuntu16_ami}"
  key_name = "${aws_key_pair.emr_key_pair.key_name}"
  instance_type = "t2.small"
  tags {
    Name = "bitcoin-ubuntu16"
  }
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  provisioner "file" {
    content      = "${data.template_file.build_install.rendered}"
    destination = "~/build_install.sh"
    connection {
      type = "ssh"
      host = "${aws_instance.bitcoin-tf-small.public_ip}"
      user     = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = "${aws_instance.bitcoin-tf-small.public_ip}"
      user     = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
    inline = [
      "chmod +x ~/build_install.sh",
      "bash ~/build_install.sh"
    ]
  }
}
