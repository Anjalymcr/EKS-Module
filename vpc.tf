
# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"

  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.project}-igw"
  }
}


# # Create public subnet for load balancer in each avialability zones
resource "aws_subnet" "public-subnet" {
   count             = var.availability_zones
   availability_zone = data.aws_availability_zones.available.names[count.index]
   vpc_id            = aws_vpc.my_vpc.id
   cidr_block        = cidrsubnet(var.aws_vpc_cidr, 8, count.index + 1) ## Starts from 10.0.1.0/24
   tags = {
     Name      = "public-subnet-${count.index}"
     Attribute = "public"
     "kubernetes.io/role/elb" = "1"
     
   }
 }

# # # Create Route Table 
resource "aws_route_table" "public_route_table" {
   vpc_id = aws_vpc.my_vpc.id

## route to internet
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.igw.id
   }

   tags = {
     Name      = "${var.project}-public-route-table"
     Attribute = "public"
     Project   = var.project
   }
 }

# # Associate Public Subnets with Public Route Table 
resource "aws_route_table_association" "public-rtassoc" {
   count          = var.availability_zones
   subnet_id      = element(aws_subnet.public-subnet.*.id, count.index)
   route_table_id = aws_route_table.public_route_table.id
 }

## Create EIP for nat Gateway
resource "aws_eip" "ngw-eip" {
  domain = "vpc"

  depends_on = [
    aws_vpc.my_vpc
  ]

}

## Create aws_nat_gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw-eip.id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [
    aws_vpc.my_vpc,
    aws_eip.ngw-eip
  ]
}

# # Create private subnet for deploying the nodes 
resource "aws_subnet" "private-subnet-nodes" {
   count                   = var.availability_zones
   availability_zone       = data.aws_availability_zones.available.names[count.index]
   vpc_id                  = aws_vpc.my_vpc.id
   cidr_block              = cidrsubnet(var.aws_vpc_cidr, 8, count.index + 4) ## Starts from 10.0.4.0/24
   map_public_ip_on_launch = false

   tags = {
     Name      = "private-subnet-node${count.index}"
     Attribute = "private"
   }
 }


# ## Create Private route table for nodes
resource "aws_route_table" "private-route-table-nodes" {
   vpc_id = aws_vpc.my_vpc.id

   route {
     cidr_block     = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.ngw.id
   }
   #route {
    #cidr_block                = local.jenkins_ip_address
   #}

   tags = {
     Name      = "${var.project}-private-route-table-nodes"
     Attribute = "private"
     Project   = var.project
   }
 }

 # ## Associate  Private Subnets with private Route Table for nodes
 resource "aws_route_table_association" "private-rtassoc" {
   count          = var.availability_zones
   subnet_id      = element(aws_subnet.private-subnet-nodes.*.id, count.index)
   route_table_id = aws_route_table.private-route-table-nodes.id
  # route_table_id = aws_route_table.private-route-table[count.index].id
 }


## Create private subnet for db
resource "aws_subnet" "private-subnet-db" {
  count                   = var.availability_zones
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr, 8, count.index + 8) ## Starts from 10.0.8.0/24
  map_public_ip_on_launch = false

  tags = {
    Name      = "private-subnet-db${count.index}"
    Attribute = "private"
  }
} 

## Create private route table for db
resource "aws_route_table" "private-route-table-db" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  } 

  tags = {
    Name      = "${var.project}-private-route-table-db"
    Attribute = "private"
    Project   = var.project
  }
} 

## Associate private subnet for db with private route table for db
resource "aws_route_table_association" "private-rtassoc-db" {
  count          = var.availability_zones
  subnet_id      = element(aws_subnet.private-subnet-db.*.id, count.index)
  route_table_id = aws_route_table.private-route-table-db.id
}













