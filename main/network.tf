resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    name = "Minecraft VPC"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/27"
  availability_zone = "ap-southeast-1a"
}

# resource "aws_subnet" "private" {
#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = "10.0.0.128/27"
#   availability_zone = "ap-southeast-1a"
# }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "minecraft" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "TLS for image pulling"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NFS"
    from_port = 2409
    to_port = 2409
    protocol = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }


  ingress {
    description = "ingress for minecraft"
    from_port = 25565
    to_port = 25565
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ingress for rcon"
    from_port = 25575
    to_port = 25575
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}