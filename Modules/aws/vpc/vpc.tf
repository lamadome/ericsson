



data "aws_availability_zones" "available" {}

module "vpc" {
  count = var.createVPC ? 1: 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"
  name                 = var.vpc_name
  cidr                 = var.cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_dns_hostnames = true
}

data "aws_vpc" "vpc"{
  count = var.createVPC ? 0 : 1
  id = var.vpc_ID
}

output vpc_id{
  value = var.createVPC ? module.vpc[0].vpc_id : var.vpc_ID
}

output public_subnets{
  value = var.createVPC ? module.vpc[0].public_subnets : var.public_subnets
}
output private_subnets{
  value = var.createVPC ? module.vpc[0].private_subnets : var.private_subnets
}
output security_group_id{
  value = aws_security_group.consul.id
}

output instance_profile{
  value = aws_iam_instance_profile.consul.name
}

resource "aws_security_group" "external_connection" {
  name_prefix = "all_worker_management"
  vpc_id      =  var.createVPC ? module.vpc[0].vpc_id:var.vpc_ID
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "consul" {
  name        = "consul"
  description = "consul"
  vpc_id      = var.createVPC ? module.vpc[0].vpc_id:var.vpc_ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    #cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    #cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    #cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  owners = ["self"]

  most_recent = true

  filter {
    name   = "name"
    values = ["hashistack-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_instance_profile" "consul" {
  name = "consul-${random_string.env.result}"
  role = aws_iam_role.consul.name
}

resource "aws_iam_role" "consul" {
  name = "consul-${random_string.env.result}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "consul" {
  name = "consul-${random_string.env.result}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "consul" {
  role       = aws_iam_role.consul.name
  policy_arn = aws_iam_policy.consul.arn
}

