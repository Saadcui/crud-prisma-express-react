data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_ip_cidr_auto = "${chomp(data.http.my_ip.response_body)}/32"
  my_ip_cidr      = coalesce(var.client_ip_cidr, local.my_ip_cidr_auto)
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow MySQL access"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    ignore_changes = [description]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-sg" }
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnets"
  # Use public subnets so the instance is truly reachable when publicly_accessible = true
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  tags = { Name = "db-subnets" }
}

resource "aws_db_instance" "mysql" {
  identifier             = "my-db"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot    = true
}
