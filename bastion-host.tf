## Create bastion host

resource "aws_instance" "bastion_host" {
  instance_type = var.bastion_host_instance_type
  ami = var.bastion_host_ami
  subnet_id = aws_subnet.public-subnet[0].id    
  vpc_security_group_ids = [aws_security_group.bastion_host_sg.id]
  key_name = var.key_name

  associate_public_ip_address = true

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 100
    volume_type = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project}-bastion-host"
  }
}


## create eip for bastion host
resource "aws_eip" "bastion_host_eip" {
  instance = aws_instance.bastion_host.id
  domain = "vpc"
}   

## Associate eip to bastion host
resource "aws_eip_association" "bastion_host_eip_association" {
  instance_id = aws_instance.bastion_host.id
  allocation_id = aws_eip.bastion_host_eip.id
}   


## Create security group for bastion host

resource "aws_security_group" "bastion_host_sg" {
  name = "${var.project}-bastion-host-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


