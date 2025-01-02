# Jenkins ec2 instance

resource "aws_instance" "jenkins" {
  ami = var.bastion_host_ami
  instance_type = "t2.medium"
  key_name = var.key_name

  #subnet_id = aws_subnet.private-subnet-nodes[0].id
  subnet_id = aws_subnet.public-subnet[0].id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]

  iam_instance_profile = aws_iam_instance_profile.jenkins-profile.name

  user_data = file("scripts/jenkins-install.sh")

  tags = {
    Name = "${var.project}-jenkins-server"
  }

  depends_on = [
    aws_security_group.jenkins-sg,
    aws_nat_gateway.ngw
    ]

}


## Jenkins security group

resource "aws_security_group" "jenkins-sg" {
  name = "${var.project}-jenkins-sg"
  description = "security group for jenkins server"
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.project}-jenkins-sg"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow bastion host to access jenkins server"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow jenkins server to access the internet"
  }
}


# Iam role for jenkins server

resource "aws_iam_role" "jenkins-role" {
  name = "jenkins-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


# Iam instance profile for jenkins server

resource "aws_iam_instance_profile" "jenkins-profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins-role.name
}

# Iam policy for jenkins server

resource "aws_iam_role_policy" "jenkins-policy" {
  name = "jenkins-policy"
  role = aws_iam_role.jenkins-role.id



  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "*"
            Effect = "Allow"
            Resource = "*"
        }       
    ]
  })
}

output "jenkins_private_ip" {
  value = aws_instance.jenkins.private_ip
  description = "private ip address of jenkins server"
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
  description = "public ip address of jenkins server"
}



