resource "aws_vpc" "main" {
cidr_block = var.cidr_block_vpc
tags = {
Name = var.vpc_name
}
}
resource "aws_subnet" "public" {
availability_zone = var.availability_zone_public
vpc_id = aws_vpc.main.id
cidr_block = var.cidr_block_public
map_public_ip_on_launch = "true"
tags = {
Name = "public"
}
}
resource "aws_subnet" "private" {
availability_zone = var.availability_zone_private
vpc_id = aws_vpc.main.id
cidr_block = var.cidr_block_private
map_public_ip_on_launch = "true"
tags = {
Name = "private"
}
}
resource "aws_internet_gateway" "gw" {
vpc_id = aws_vpc.main.id
tags = {
Name = var.internet_gateway_name
}
}
resource "aws_route_table" "route" {
vpc_id = aws_vpc.main.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.gw.id
}
tags = {
Name = "publicroute"
}
}
resource "aws_route_table_association" "a1" {
subnet_id = aws_subnet.public.id
route_table_id = aws_route_table.route.id
}
resource "aws_eip" "eip" {
vpc = "true"
}
resource "aws_nat_gateway" "natgw" {
allocation_id = aws_eip.eip.id
subnet_id = aws_subnet.public.id
tags = {
Name = var.nat_gateway_name
}
}
resource "aws_route_table" "privateroute" {
vpc_id = aws_vpc.main.id
route {
cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.natgw.id
}
tags = {
Name = "privateroute"
}
}
resource "aws_route_table_association" "a2" {
subnet_id = aws_subnet.private.id
route_table_id = aws_route_table.privateroute.id
}



## Security Group##
resource "aws_security_group" "TestSG" {
  description = "Allow traffic"
  vpc_id      = aws_vpc.main.id
  name        = var.instance_security_group_name

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }


  tags = {
    Name = "TestSG"
  }
}




# To create ec2 instance (public)

resource "aws_instance" "Publicserver" {
    ami = var.public_instance_ami
    instance_type = var.public_instance_type
    security_groups = [aws_security_group.TestSG.id]
    subnet_id = aws_subnet.public.id
    key_name               = var.key_name
    associate_public_ip_address = true
    tags = {
      Name              = var.public_instance_name
    }
}


# To create ec2 instance (Private)

resource "aws_instance" "Privateserver" {
    ami = var.private_instance_ami
    instance_type = var.private_instance_type
    security_groups = [aws_security_group.TestSG.id]
    subnet_id = aws_subnet.private.id
    key_name               = var.key_name
    associate_public_ip_address = false
    tags = {
      Name              = var.private_instance_name
    }
}



#  for creating ALB

resource "aws_lb" "my-test-lb" {
  name               = var.load_balancer_name
  internal           = false
  load_balancer_type = var.load_balancer_type
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.private.id]
  #enable_deletion_protection = true

}

resource "aws_lb_target_group" "my-alb-tg" {
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  name        = "my-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "my-tg-attachment1" {
  target_group_arn = aws_lb_target_group.my-alb-tg.arn
  target_id        = aws_instance.Publicserver.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my-tg-attachment2" {
  target_group_arn = aws_lb_target_group.my-alb-tg.arn
  target_id        = aws_instance.Privateserver.id
  port             = 80
}

resource "aws_security_group" "alb-sg" {
  name   = var.load_balancer_security_group
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "http_allow" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb-sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.alb-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

