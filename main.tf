provider "aws" {
    region = "eu-west-3"
}
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc",
    }
}
module "myapp-subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    vpc_id = aws_vpc.myapp-vpc.id
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    env_prefix = var.env_prefix
    my_ip = var.my_ip
    instance_type = var.instance_type
    public_key_path = var.public_key_path
    subnet_id = module.myapp-subnet.subnet.id
    avail_zone = var.avail_zone
}
