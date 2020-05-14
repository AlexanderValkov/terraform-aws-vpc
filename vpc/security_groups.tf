# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#NATSG
resource "aws_security_group" "nat" {
  name        = "NATSG"
  description = "NATSG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for s in aws_subnet.private : s.cidr_block]
    description = "HTTPS from private subnet"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [for s in aws_subnet.private : s.cidr_block]
    description = "HTTP from private subnet"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_ssh_from]
    description = "SSH access to the NAT instance from your home network (over the Internet gateway)"
  }

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [for s in aws_subnet.private : s.cidr_block]
    description = "Ping from private subnet"
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [for s in aws_subnet.private : s.cidr_block]
    description = "SSH to private subnet"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access to the Internet"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access to the Internet"
  }

  tags = {
    Name = "NATSG"
  }
}


resource "aws_security_group" "private" {
  name        = "private"
  description = "default group for instances in private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.nat.id]
    description     = "SSH Access from NAT Instance"
  }

  egress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Ping inside VPC"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for updates and such"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for updates and such"
  }


  tags = {
    Name = "private"
  }
}
