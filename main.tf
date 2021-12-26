provider "aws" {
    region = "eu-west-3"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {Name = "${var.env_prefix}-subnet-1"}

  tags = {
    Name = "${var.env_prefix}-vpc"
  }

}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = module.vpc.vpc_id
    env_prefix = var.env_prefix
    my_ip = var.my_ip
    instance_type = var.instance_type
    public_key_path = var.public_key_path
    subnet_id = module.vpc.public_subnets[0]
    avail_zone = var.avail_zone
}
