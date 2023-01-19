# Define external IP - NAT Gateway - use NAT gateway for EC2 in private VPC subnet to connect securely over the Internet 

#create elastic IP
resource "aws_eip" "customVpc-nat" {
  vpc      = true
}

#create nat gateway
resource "aws_nat_gateway" "customVpc-nat-gw" {
  allocation_id = aws_eip.customVpc-nat.id
  subnet_id     = aws_subnet.customVpcOne-public-1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.customVpcOne-gw]
}


#create route table

resource "aws_route_table" "customVpcOne-private-r" {
  vpc_id = aws_vpc.customVpcOne.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.customVpc-nat-gw.id
  }


  tags = {
    Name = "customVpcOne-private-r"
  }
}


# route association private 
resource "aws_route_table_association" "customVpcOne-private-1-a" {
  subnet_id      = aws_subnet.customVpcOne-private-1.id
  route_table_id = aws_route_table.customVpcOne-private-r.id
}
