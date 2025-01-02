##Create RDS Instance

resource "aws_db_instance" "wilt_db" {
  identifier = "wilt-db"
  engine = "postgres"
  engine_version = "14.10"
  instance_class = var.db_instance_class
  allocated_storage = 20

  db_name = var.POSTGRES_DB
  username = var.POSTGRES_USER
  password = var.POSTGRES_PASSWORD

  db_subnet_group_name = aws_db_subnet_group.wilt_db.name
  vpc_security_group_ids = [aws_security_group.wilt_db_sg.id]

  skip_final_snapshot = true

  tags = {
    Name = "wilt-db"
  }
  
  depends_on = [
    aws_db_subnet_group.wilt_db, 
    aws_security_group.wilt_db_sg
    ]
}

##Create RDS Subnet Group

resource "aws_db_subnet_group" "wilt_db" {
  name = "wilt-db-subnet-group"
  subnet_ids = [
    aws_subnet.private-subnet-db[0].id,
    aws_subnet.private-subnet-db[1].id,
    ]


  tags = {
    Name = "wilt-db-subnet-group"
  }
}

##Create RDS Security Group

resource "aws_security_group" "wilt_db_sg" {
  name = "wilt-db-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block]
  }

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.cluster_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wilt-db-sg"
  }
}

output "db_endpoint" {
  value = aws_db_instance.wilt_db.endpoint
}


