#Get availablity zones 
data "aws_availability_zones" "available" {
  state = "available"
}

# Create AWS VPC
resource "aws_vpc" "customVpcOne" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "customVpcOne"
  }
}

# Create a subnets in custom VPC

resource "aws_subnet" "customVpcOne-public-1" {
  vpc_id                  = aws_vpc.customVpcOne.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "customVpcOne-public-1"
  }
}


resource "aws_subnet" "customVpcOne-public-2" {
  vpc_id                  = aws_vpc.customVpcOne.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "customVpcOne-public-2"
  }
}


resource "aws_subnet" "customVpcOne-private-1" {
  vpc_id                  = aws_vpc.customVpcOne.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = false
  tags = {
    Name = "customVpcOne-private-1"
  }
}




# Define the Internet Gateway

resource "aws_internet_gateway" "customVpcOne-gw" {
  vpc_id = aws_vpc.customVpcOne.id

  tags = {
    Name = "customVpcOne-ig"
  }
}


# Define routing table for the custom VPC
resource "aws_route_table" "customVpcOne-r" {
  vpc_id = aws_vpc.customVpcOne.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.customVpcOne-gw.id
  }


  tags = {
    Name = "customVpcOne-r"
  }
}



# Define the routing association between a route table and a subnet or a route table and an internet gateway or virtual private gateway
resource "aws_route_table_association" "customVpcOne-public-1-a" {
  subnet_id      = aws_subnet.customVpcOne-public-1.id
  route_table_id = aws_route_table.customVpcOne-r.id
}

resource "aws_route_table_association" "customVpcOne-public-1-b" {
  subnet_id      = aws_subnet.customVpcOne-public-2.id
  route_table_id = aws_route_table.customVpcOne-r.id
}
