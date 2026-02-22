packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

data "amazon-ami" "windows_2019" {
  filters = {
    name = "Windows_Server-2019-English-Full-Base-*"
  }
  most_recent = true
  owners      = ["801119661308"]
  region      = "us-east-2"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


source "amazon-ebs" "windows-2019" {
  ami_name       = "my-windows-2019-aws-{{timestamp}}"
  communicator   = "winrm"
  instance_type  = "t3.small"
  region         = "us-east-2"
  source_ami     = "${data.amazon-ami.windows_2019.id}"
  user_data_file = "./scripts/SetUpWinRM.ps1"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"
  tags = {
    "Name"        = "MyWindowsImage"
    "Environment" = "Production"
    "OS_Version"  = "Windows"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

data "amazon-ami" "windows_2022" {
  filters = {
    name = "Windows_Server-2022-English-Full-Base-*"
  }
  most_recent = true
  owners      = ["801119661308"]
  region      = "us-east-1"
}

source "amazon-ebs" "windows-2022" {
  ami_name       = "my-windows-2022-aws-{{timestamp}}"
  communicator   = "winrm"
  instance_type  = "t3.micro"
  region         = "us-east-1"
  source_ami     = "${data.amazon-ami.windows_2022.id}"
  user_data_file = "./scripts/SetUpWinRM.ps1"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"
}

build {
  sources = ["source.amazon-ebs.windows-2019", "source.amazon-ebs.windows-2022", ]

  post-processor "manifest" {
  }
}
