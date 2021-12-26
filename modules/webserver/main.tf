resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = var.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
     ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name= "${var.env_prefix}-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true
    owners = ["amazon"]
    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}
resource "aws_key_pair" "ssh-key" {
    key_name = "server_key"
    public_key = file(var.public_key_path)
}
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  availability_zone = var.avail_zone
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  key_name = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
  tags = {
      Name = "${var.env_prefix}-server"
  }
  user_data = file("entry-script.sh")
#   connection {
#     type = "ssh"
#     host= self.public_ip
#     user= "ec2-user"
#     private_key = file(var.private_key_path)
#   }
#   provisioner "file" {
#     source = "entry-script.sh"
#     destination = "/home/ec2-user/entry-script.sh"
#   }
#   provisioner "remote-exec" {
#       script = "/home/ec2-user/entry-script.sh"
#   }
#   provisioner "local-exec" {
#     command = "echo ${self.public_ip} >> ./the_public_given_addresses.txt"
#   }
}
