module "s3" {
  source = "./modules/s3"

  nginx_bucket_name = var.nginx_bucket_name
}

module "ec2" {
  source = "./modules/ec2"

  region = var.region

  ami           = "ami-0fef2f5dd8d0917e8"
  instance_type = "t2.micro"

  nginx_bucket_name = var.nginx_bucket_name

  nginx_ec2_role         = var.nginx_ec2_role
  nginx_instance_profile = var.nginx_instance_profile
  nginx_log_group = var.nginx_log_group
  nginx_log_stream = var.nginx_log_stream
}

module "iam" {
  source = "./modules/iam"

  region = var.region

  nginx_bucket_name = var.nginx_bucket_name

  nginx_ec2_role         = var.nginx_ec2_role
  nginx_instance_profile = var.nginx_instance_profile

  nginx_log_group = var.nginx_log_group
  nginx_log_stream = var.nginx_log_stream
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  region = var.region

  nginx_log_group = var.nginx_log_group
  nginx_log_stream = var.nginx_log_stream

  ec2_instance = module.ec2.ec2_instance
}
