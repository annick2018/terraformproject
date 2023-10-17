provider "aws" {
  region = "us-east-2" # Change to your desired AWS region
}

resource "aws_vpc" "cacivpc" {
  cidr_block = "10.0.0.0/16" # Update with your desired VPC CIDR block
}

resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.cacivpc.id
  cidr_block        = element(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"], count.index)
  availability_zone = element(["us-east-2a", "us-east-2b", "us-east-2c"], count.index)
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_role"{
    name = "ec2_role"
    role = aws_iam_role.ec2_role.name
}
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-sg-"

  ingress {
    from_port   = 4001
    to_port     = 4003
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet[0].cidr_block, aws_subnet.private_subnet[1].cidr_block, aws_subnet.private_subnet[2].cidr_block]
  }
}

resource "aws_instance" "ec2_instances" {
  count         = 3
  ami           = "ami-080c09858e04800a1" # Replace with your desired Amazon Linux AMI
  instance_type = "t3.micro"
  subnet_id     = element(aws_subnet.private_subnet[*].id, count.index)
  iam_instance_profile = aws_iam_role.ec2_role.name

  root_block_device {
    volume_size = 8 # Size of the root volume
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 100 # 100G EBS volume size
    volume_type = "gp2" # Change the volume type if needed
  }
}

resource "aws_lb" "caci_lb" {
  name               = "caci-lb"
  load_balancer_type = "network"
  subnets            = aws_subnet.private_subnet[*].id
  enable_deletion_protection = false # Disable deletion protection (optional)

  enable_cross_zone_load_balancing = true

  internal = true

  enable_http2 = true

  #enable_deletion_protection = false # Disable deletion protection (optional)
}

resource "aws_lb_target_group" "ec2_target_group" {
  name        = "ec2-target-group"
  port        = 443
  protocol    = "TCP"
  vpc_id      = aws_vpc.cacivpc.id
  target_type = "instance"
}

resource "aws_lb_listener" "ec2_listener" {
  load_balancer_arn = aws_lb.caci_lb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_target_group.arn
  }
}

resource "aws_spot_instance_request" "spot_ec2" {
 # count                 = 3
  ami                   = "ami-080c09858e04800a1" # Replace with your desired Amazon Linux AMI
  instance_type         = "t3.micro"
  #subnet_id             = element(aws_subnet.private_subnet[*].id, count.index)
 # iam_instance_profile = aws_iam_role.ec2_role.name
  spot_price            = "0.50" # Set your desired spot price
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 100
    volume_type = "gp2"
  }
  tags = {
    Name = "spot-ec2-instance"
  }
}

output "caci_lb_dns_name" {
  value = aws_lb.caci_lb.dns_name
}





