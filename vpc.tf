# Creating a VPC!
resource "aws_vpc" "main" {
  # IP Range for the VPC
  cidr_block = var.vpc_cidr
  
  # Enabling automatic hostname assigning
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Deployment = var.deployment_tag
    Name = "${var.deployment_tag}-vpc"
  }
}


resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)

 map_public_ip_on_launch = true
 
 tags = {
    Deployment = var.deployment_tag
    Name = "(${var.deployment_tag}) Public Subnet ${count.index + 1}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
  Deployment = var.deployment_tag
  Name = "(${var.deployment_tag}) Private Subnet ${count.index + 1}"
 }
}


# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.main,
    aws_subnet.private_subnets,
    aws_subnet.public_subnets

  ]
  
  # VPC in which it has to be created!
  vpc_id = aws_vpc.main.id

  tags = {
    Deployment = var.deployment_tag
    Name = "IG-Public-&-Private-VPC-${var.deployment_tag}"
  }
}

# Creating an Route Table for the public subnet!
resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.main,
    aws_internet_gateway.Internet_Gateway,
    aws_nat_gateway.nat_gateway
  ]

   # VPC ID
  vpc_id = aws_vpc.main.id


  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }
  route {
    ipv6_cidr_block        = "::/0"
     gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Deployment = var.deployment_tag
    Name = "Route Table for Internet Gateway (${var.deployment_tag})"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.Public-Subnet-RT.id
}


resource "aws_route_table" "Private-Subnet-RT" {
  depends_on = [
    aws_vpc.main,
    aws_internet_gateway.Internet_Gateway,
    aws_nat_gateway.nat_gateway
  ]

   # VPC ID
  vpc_id = aws_vpc.main.id


  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
    #gateway_id = aws_internet_gateway.Internet_Gateway.id
  }
  route {
    ipv6_cidr_block        = "::/0"
     gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Deployment = var.deployment_tag
    Name = "Route Table for NAT Gateway (${var.deployment_tag})"
  }
}


resource "aws_route_table_association" "private_subnet_asso" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.public_subnets,
    aws_subnet.private_subnets,
    aws_route_table.Private-Subnet-RT
  ]

# Private Subnet ID
count = length(var.private_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  

#  Route Table ID
  route_table_id = aws_route_table.Private-Subnet-RT.id
}


resource "aws_eip" "nat_gateway" {
  vpc      = true
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [ aws_eip.nat_gateway ]
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public_subnets[0].id
  tags = {
    Deployment = var.deployment_tag
    "Name" = "NatGateway"
  }
}




