resource "aws_db_subnet_group" "default" {
  name        = "aurora-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.main-private-1.id, aws_subnet.main-private-2.id]
  #subnet_ids  = var.subnets
  #tags        = module.this.tags
}

 

resource "aws_db_parameter_group" "default" {
  name        = "auroradb-parameters"
  family      = var.cluster_family
  description = "aurora parameter group"

  parameter {
    name  = "max_allowed_packet"
    value = "16777216"
  }
}





resource "aws_rds_cluster_parameter_group" "default" {
  #count       = module.this.enabled ? 1 : 0
  #name_prefix = "${module.this.id}${module.this.delimiter}"
  #name_prefix = "${module.this.id}${module.this.delimiter}"
  description = "DB cluster parameter group"
  family      = var.cluster_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
}




# resource "aws_db_instance" "mariadb" {
#   allocated_storage       = 100 # 100 GB of storage, gives us more IOPS than a lower number
#   engine                  = "mariadb"
#   engine_version          = "10.4.13"
#   instance_class          = "db.t3.small" # use micro if you want to use the free tier
#   identifier              = "mariadb"
#   name                    = "mariadb"
#   username                = "root"           # username
#   password                = var.RDS_PASSWORD # password
#   db_subnet_group_name    = aws_db_subnet_group.mariadb-subnet.name
#   parameter_group_name    = aws_db_parameter_group.mariadb-parameters.name
#   multi_az                = "false" # set to true to have high availability: 2 instances synchronized with each other
#   vpc_security_group_ids  = [aws_security_group.allow-mariadb.id]
#   storage_type            = "gp2"
#   backup_retention_period = 30                                          # how long you’re going to keep your backups
#   availability_zone       = aws_subnet.main-private-1.availability_zone # prefered AZ
#   skip_final_snapshot     = true                                        # skip final snapshot when doing terraform destroy
#   tags = {
#     Name = "mariadb-instance"
#   }
# }

resource "aws_rds_cluster" "Aurora" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-mysql"  
  engine_mode            = "serverless"  
  db_subnet_group_name    = aws_db_subnet_group.default.name
        #db_subnet_group_name   = join("", aws_db_subnet_group.default.*.name)
        #db_parameter_group_name  = aws_db_parameter_group.default.name
        #db_parameter_group_name  = join("", aws_db_parameter_group.default.*.name)
        #publicly_accessible       = var.publicly_accessible
        #engine                  = "aurora-postgresql"
  availability_zones      = ["eu-west-1a", "eu-west-1b"]

  database_name           = "xerrismyauroradb"  
  enable_http_endpoint    = true  
  master_username         = "root"
  master_password         = "chang3000eme321"
  backup_retention_period = 1
  
  skip_final_snapshot     = true
  
  scaling_configuration {
    auto_pause               = true
    min_capacity             = 1    
    max_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }  

depends_on = [
    aws_db_subnet_group.default,
    aws_db_parameter_group.default,
    #aws_iam_role.enhanced_monitoring,
    #aws_rds_cluster.secondary,
    aws_rds_cluster_parameter_group.default,
  ]
}