provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
resource "aws_key_pair" "testkey" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_vpc" "test-vpc" {
   cidr_block = "10.0.0.0/24"
   tags = {
     Name = "test"
   }
 }

# # Create Internet Gateway

resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.test-vpc.id
   tags = {
     Name = "test"
   }

 }
# # Create Custom Route Table

 resource "aws_route_table" "test-route-table" {
   vpc_id = aws_vpc.test-vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
   }

   route {
     ipv6_cidr_block = "::/0"
     gateway_id      = aws_internet_gateway.gw.id
   }

   tags = {
     Name = "test"
   }
 }

# # Create a Subnet

 resource "aws_subnet" "subnet-1" {
   vpc_id            = aws_vpc.test-vpc.id
   cidr_block        = "10.0.0.0/25"
   availability_zone = "us-east-1a"

   tags = {
     Name = "test-subnet"
   }
 }
  resource "aws_subnet" "subnet-2" {
   vpc_id            = aws_vpc.test-vpc.id
   cidr_block        = "10.0.0.128/25"
   availability_zone = "us-east-1b"

   tags = {
     Name = "test-subnet2"
   }
 }

# # Associate subnet with Route Table
 resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.subnet-1.id
   route_table_id = aws_route_table.test-route-table.id
 }
  resource "aws_route_table_association" "b" {
   subnet_id      = aws_subnet.subnet-2.id
   route_table_id = aws_route_table.test-route-table.id
 }

 resource "aws_main_route_table_association" "main_route" {
  vpc_id         = aws_vpc.test-vpc.id
  route_table_id = aws_route_table.test-route-table.id
}

 resource "aws_security_group" "allow_web" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
   vpc_id      = aws_vpc.test-vpc.id

   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "allow_web"
   }
 }


resource "aws_security_group" "test_alb_security_group" {
    vpc_id = aws_vpc.test-vpc.id
    ingress {
        from_port = 22
        to_port = 22
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
     Name = "test_alb"
   }
}
resource "aws_launch_configuration" "test_launch_configuration" {

    name = "test_launch_configuration"
    image_id = var.image_id

    instance_type = var.instanceType
    key_name = var.key_name
    security_groups = [aws_security_group.test_launch_config_security_group.id]

    associate_public_ip_address = true
    lifecycle {
        # ensure the new instance is only created before the other one is destroyed.
        create_before_destroy = true
    }   
}
resource "aws_security_group" "test_launch_config_security_group" {
    vpc_id = aws_vpc.test-vpc.id
    ingress {
        from_port = 22
        to_port = 22
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
     Name = "test-launch"
   }    
}


resource "aws_autoscaling_group" "test_autoscaling_group" {
    name = "test-autoscaling-group"
    desired_capacity = 1 # ideal number of instance alive
    min_size = 1 # min number of instance alive
    max_size = 2 # max number of instance alive
    health_check_type = "ELB"

    # allows deleting the autoscaling group without waiting
    # for all instances in the pool to terminate
    force_delete = true

    launch_configuration = aws_launch_configuration.test_launch_configuration.id
    vpc_zone_identifier = [
        aws_subnet.subnet-1.id,
        aws_subnet.subnet-2.id
    ]
    timeouts {
        delete = "15m" # timeout duration for instances
    }
    lifecycle {
        # ensure the new instance is only created before the other one is destroyed.
        create_before_destroy = true
    }
}

