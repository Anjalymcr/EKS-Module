## Create Application Load Balancer
resource "aws_lb" "my_lb" {
  name = "${var.project}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = aws_subnet.public-subnet.*.id

  tags = {
    Name                       = "${var.project}-alb"
    "ingress.k8s.aws/stack"    = "${var.project}-alb"
    "elbv2.k8s.aws/cluster"    = var.eks_cluster_name
    "ingress.k8s.aws/resource" = "LoadBalancer"
  }
}

## Create Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name = "${var.project}-alb-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

