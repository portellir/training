#
# DO NOT DELETE THESE LINES!
#
# Your AMI ID is:
#
#     ami-f2b39792
#
# Your subnet ID is:
#
#     subnet-f4056fac
#
# Your security group ID is:
#
#     sg-578da130
#
# Your Identity is:
#
#     HashiDays-2017-tf-bat
#

variable "num_webs" {
  default = "2"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_instance" "web" {
  # ...
  count                  = "${var.num_webs}"
  ami                    = "ami-f2b39792"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-f4056fac"
  vpc_security_group_ids = ["sg-578da130"]

  tags {
    Identity = "HashiDays-2017-tf-bat"
    Foo      = "bar"
    Zip      = "zap"

    #Name     = "web ${count.index-1}/{var.num_webs}" # "web 1/2"
  }
}

output "public_ip" {
  value = ["${aws_instance.web.*.public_ip}"]
}

output "public_dns" {
  value = ["${aws_instance.web.*.public_dns}"]
}

# This is is a black-box
module "example" {
  source  = "./example-module"   #referencing where to find the module
  command = "${var.sec_command}" #changing the command of the provisioner
}

variable "sec_command" {
  default = "echo 'Dude this is another command'"
}

# Add a configuration to use Atlas as the remote state storage backend
terraform {
  backend "atlas" {
    name = "portellir/training"
  }
}

# Add new provider and create a new dnsimple_record resource
provider "dnsimple" {
  token   = "something"
  account = "nope"
}

resource "dnsimple_record" "example" {
  # ...
  domain = "terraform.rocks"
  type   = "A"
  name   = "something"
  value  = "${aws_instance.web.0.public_ip}" # OR: "{element(aws_instance.web.*.public_ip, 0)}" OR: count.index instead of 0
}
