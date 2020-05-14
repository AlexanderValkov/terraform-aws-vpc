provider "aws" {
  region = var.region
}


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_tag_Name
  }
}


resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.subnet.public)
  availability_zone       = join("", [var.region, var.subnet.public[count.index].az_postfix])
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name  = var.subnet.public[count.index].subnet_tag_Name
    scope = "public"
  }
}


resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.subnet.private)
  availability_zone       = join("", [var.region, var.subnet.private[count.index].az_postfix])
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index + length(var.subnet.public))
  map_public_ip_on_launch = false

  tags = {
    Name  = var.subnet.private[count.index].subnet_tag_Name
    scope = "private"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public"
  }
}


resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


data "aws_ami" "nat_amzn" {
  most_recent = true
  name_regex  = "^amzn-ami-vpc-nat"
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "nat" {
  ami                         = data.aws_ami.nat_amzn.image_id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.nat.id]
  source_dest_check           = false
  associate_public_ip_address = true

  tags = {
    Name = "NAT"
  }
}


resource "aws_eip" "nat" {
  instance = aws_instance.nat.id
  vpc      = true
}


resource "aws_route" "nat" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = aws_instance.nat.id
}
