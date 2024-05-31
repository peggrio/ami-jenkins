packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami" {
  type    = string
  default = "ami-04b70fa74e45c3917"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "vpc_id" {
  type    = string
  default = "vpc-023f27855f38a83dd"
}

variable "subnet_id" {
  type    = string
  default = "subnet-06242053329a9c97d"
}

source "amazon-ebs" "jenkins-ami" {
  region        = var.region
  source_ami    = var.source_ami
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  ami_name      = "jenkins-{{timestamp}}"
  tags = {
    Name = "Jenkins - {{timestamp}}"
  }
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
}

build {
  sources = ["sources.amazon-ebs.jenkins-ami"]

  provisioner "file" {
    source      = "install-jenkins.sh"
    destination = "/tmp/install-jenkins.sh"
  }

  provisioner "file" {
    source      = "install-nginx.sh"
    destination = "/tmp/install-nginx.sh"
  }

  provisioner "file" {
    source      = "configure-nginx.sh"
    destination = "/tmp/configure-nginx.sh"
  }

  provisioner "file" {
    source      = "jenkins.conf"
    destination = "/tmp/jenkins.conf"
  }

  provisioner "file" {
    source      = "plugins.txt"
    destination = "/tmp/plugins.txt"
  }


  provisioner "shell" {
    inline = [
      "sudo chmod +x /tmp/install-jenkins.sh",
      "sudo chmod +x /tmp/install-nginx.sh",
      "sudo chmod +x /tmp/configure-nginx.sh",
      "/tmp/install-jenkins.sh",
      "/tmp/install-nginx.sh",
      "/tmp/configure-nginx.sh",
    ]
  }


}