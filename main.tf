resource "aws_docdb_subnet_group" "main" {
  name       = "${var.name}-${var.env}"
  subnet_ids = var.subnets
  tags = merge(var.tags,{"Name"="${var.name}-${var.env}-sng"})
}

resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "DOCDB"
    from_port   = var.port_no
    to_port     = var.port_no
    protocol    = "tcp"
    cidr_blocks = var.allow_db_cidr

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = merge(var.tags,{"Name"="${var.name}-${var.env}-sg"})
}

resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "docdb4.0"
  name        = "${var.name}-${var.env}"
  description = "${var.name}-${var.env}"
  tags = merge(var.tags,{"Name"="${var.name}-${var.env}-pg"})


}
resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.name}-${var.env}"
  engine                  = "docdb"
  master_username         = data.aws_ssm_parameter.db_user.value
  master_password         = data.aws_ssm_parameter.db_pass.value
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name = aws_docdb_subnet_group.main.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  engine_version = var.engine_version
  kms_key_id = var.kms_arn
  port = var.port_no
  storage_encrypted = true
  tags = merge(var.tags,{"Name"="${var.name}-${var.env}-cluster"})
  vpc_security_group_ids = [aws_security_group.main.id]

}


resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "${var.name}-${var.env}-${count.index+1}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.instance_class
}





