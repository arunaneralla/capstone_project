# Define our VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "aruna004-vpc"
  }
}

# Define the public subnets
resource "aws_subnet" "public_subnet" {
  depends_on=[
    aws_vpc.main,
  ]
  count = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.public_subnets_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "aruna004-public-subnet-${count.index+1}"
  }
}

# Define the private subnets
resource "aws_subnet" "private_subnet" {
  depends_on=[
    aws_vpc.main,
  ]
  count = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.private_subnets_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "aruna004-private-subnet-${count.index+1}"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "aruna004 VPC IGW"
  }
}

# Define the NAT gateway
resource "aws_nat_gateway" "ngw" {
  count = length(var.private_subnets_cidr)
  connectivity_type = "private"
  subnet_id = element(aws_subnet.private_subnet.*.id,count.index)
  tags = {
    Name = "aruna004 VPC NGW"
  }
}

# Define the route table for public subnet
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "aruna004 Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-rt-assoc" {
    count = length(var.public_subnets_cidr)
    subnet_id = element(aws_subnet.public_subnet.*.id,count.index)
    route_table_id = "${aws_route_table.public-rt.id}"
}

# Define the route table for private subnet
resource "aws_route_table" "private-rt" {
  vpc_id   = aws_vpc.main.id
  count = length(var.public_subnets_cidr)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.ngw.*.id,count.index)
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Assign the route table to the private Subnets
resource "aws_route_table_association" "nat" {
  count = length(var.private_subnets_cidr)
  route_table_id = element(aws_route_table.private-rt.*.id,count.index)
  subnet_id      = element(aws_subnet.private_subnet.*.id,count.index)
}

resource "aws_ec2_tag" "vpc_tag" {
  resource_id = aws_vpc.main.id
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_subnet_tag" {
  count       = length(var.private_subnets_cidr)
  resource_id = element(aws_subnet.private_subnet.*.id,count.index)
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_subnet_cluster_tag" {
  count       = length(var.private_subnets_cidr)
  resource_id = element(aws_subnet.private_subnet.*.id,count.index)
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "public_subnet_tag" {
  count       = length(var.public_subnets_cidr)
  resource_id = element(aws_subnet.public_subnet.*.id,count.index)
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_cluster_tag" {
  count       = length(var.public_subnets_cidr)
  resource_id = element(aws_subnet.public_subnet.*.id,count.index)
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}
