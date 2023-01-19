# Get availability zones 
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# Get ubuntu ami id
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# create aws key pair 
resource "aws_key_pair" "aws-ec2-key" {
  key_name   = "aws_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

#create aws ec2 instance in public subnet
resource "aws_instance" "pub-instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  availability_zone      = data.aws_availability_zones.available.names[0]
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.allow-customvpc-ssh.id, aws_security_group.allow-customvpc-http.id]
  subnet_id              = aws_subnet.customVpcOne-public-1.id
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.PATH_TO_PRIVATE_KEY)
    host        = self.public_ip
    port        = 22
    agent       = true
  }
  provisioner "file" {
    source      = "installNginx.sh"
    destination = "/tmp/installNginx.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.PATH_TO_PRIVATE_KEY)
      host        = self.public_ip
      port        = 22
      agent       = true
    }
    inline = [
      "chmod +x /tmp/installNginx.sh",
      "sudo /tmp/installNginx.sh",
    ]
  }
  tags = {
    Name = "pub-instance"
  }

}


#create aws ec2 instance in public subnet
resource "aws_instance" "priv-instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  availability_zone      = data.aws_availability_zones.available.names[2]
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.allow-customvpc-ssh.id]
  subnet_id              = aws_subnet.customVpcOne-private-1.id


  tags = {
    Name = "priv-instance"
  }

}