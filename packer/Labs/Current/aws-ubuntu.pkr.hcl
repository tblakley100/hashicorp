packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "my-ubuntu-everything-variables"
}

locals {
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_regions" {
  type    = list(string)
  default = ["us-east-2"]
}

variable "tags" {
  type = map(string)
  default = {
    "Name"        = "MyUbuntuImage"
    "Environment" = "Production"
    "OS_Version"  = "Ubuntu 22.04"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

source "amazon-ebs" "ubuntu" {
  #ami_name      = "packer-ubuntu-aws-{{timestamp}}"
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  ami_regions   = "${var.ami_regions}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags         = "${var.tags}"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}