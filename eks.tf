module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = aws_subnet.private-subnet-nodes[*].id

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true


  cluster_security_group_id = aws_security_group.cluster_sg.id

 
  enable_irsa = true


  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
    } 
  }

  eks_managed_node_group_defaults = {
    disk_size = 20
    key_name = aws_key_pair.dark_watch_key.key_name
    enable_monitoring = true
    eni_delete = true
    create_launch_template = true
    user_data = <<EOF
    #!/bin/bash
    echo "Hello, World!"
    EOF
  }

  eks_managed_node_groups = {
    "${var.eks_node_group_name}" = {
      min_size = 1
      max_size = 2
      desired_size = 1

      instance_type = var.node_instance_type
      capacity_type = "ON_DEMAND"
      vpc_security_group_ids = [aws_security_group.node_group_sg.id]

      depends_on = [aws_security_group.node_group_sg,
                    aws_security_group.cluster_sg,
                    aws_vpc.my_vpc,
                    aws_subnet.private-subnet-nodes,
                    aws_internet_gateway.igw,
                    aws_route_table.private-route-table-nodes,
                    aws_route_table.public_route_table,
                    aws_route_table_association.private-rtassoc,
                    aws_route_table_association.public-rtassoc,
                    ]
    }
  }
}


## Create security group for cluster
resource "aws_security_group" "cluster_sg" {
  name_prefix = "cluster-sg"
  vpc_id = aws_vpc.my_vpc.id

  ## Ingress rule for cluster

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

## Create security group for node group
resource "aws_security_group" "node_group_sg" {
  name_prefix = "node-group-sg"
  vpc_id = aws_vpc.my_vpc.id

## Ingress rule for node group

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


data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}


