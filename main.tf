provider "aws" { region = "ap-south-1" }

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "VPC" }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "Public Subnet" }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "Internet Gateway" }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = { Name = "Route Table" }
}

resource "aws_route_table_association" "my_subnet_association" {
  subnet_id = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_sg" {
  name = "portfolio-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Security Group" }
}
resource "aws_instance" "my_server" {
  ami = "ami-0522ab6e1ddcc7055"
  instance_type = "t3.micro"
  key_name = "aws-key"
  subnet_id = aws_subnet.my_public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = { Name = "The Server" }
}
output "server_public_ip" {
  value = aws_instance.my_server.public_ip
}