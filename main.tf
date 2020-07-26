provider "aws" {
  region = var.region

  endpoints {
    ec2      = "http://localhost:4597"
    dynamodb = "http://localhost:4569"
    s3       = "http://localhost:4572"
    sqs      = "http://localhost:4576"
    kms      = "http://localhost:4599"
    sts      = "http://localhost:4592"
  }
}

resource "aws_sqs_queue" "localstack_queue" {
  name                        = "${var.application_name}_${terraform.workspace}_localstack_queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = false
  visibility_timeout_seconds  = 30
}

resource "aws_kms_key" "a" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  is_enabled              = true
}

resource "aws_kms_alias" "a" {
  name          = "alias/localstack-key"
  target_key_id = aws_kms_key.a.key_id
}

resource "aws_key_pair" "deployer" {
  key_name   = "localstack-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDn0orvgwywqarPO4BIQ7S8/s5xpO0wFv7Dhz5fO4n3IXtH+bJ8DJUzHaHksFelZ4ZQNh1w2qlgDIVn/GUjML2zlI2ne5kXWe5ZbOx6nEoU9ZUvn6ljydThi0bxzrAOj441iom2BePUNFkzvPbRdrDrtpJXh2ogy7SN7903PT38zqvyxbDs04zqrJIbLbXICKshv8N96OwdiXCepQgYDglMhz3agtUjMsbkHUngR4A6K0IZMDiDW7T8AelD+Ly5LiRfjs2jRwJe3bhDR37slWiMU9Z1plExxKTC83+1mkTpP0h5xDfyj8mvkkVkVMub4tC/u+munyCJHMZdT/IsjNp44qaJ8qpXmIEhJDnT2bKQ3aXag+XNp34CYt7X5W/tR+Ba8uosBDikYHKKeqd9vktfY3j7aFzi1ZIQFHPvCkCjc/iHkK4rpYDbftYcoJV2DN5yfSiO68zKfrDdpTuHOU650NRnmSzci3UhuUWyfEBATDdVzkvLiBHuyXwtzJSSx9Pq0TQPWGY8ri+xl42eM549cZlDrkqzCbMI4EU76hQzUB1WoY5YBRWQIjaZ0gfNgDQq3dJpH7u6u0WEMwTz+KXLaLY+ed//5Zmg+TtxITKRF/UmdcSjut7tW+T233/eNJh2Mp4IRZs5tc7jFE7lcMkd9A00Jqak3w4ULfyEe9hypw== cristianandres92@gmail.com"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "HelloWorld"
  }
}
