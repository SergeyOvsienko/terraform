provider "aws" {
  region     = "${var.aws_region}"
}

data "aws_availability_zones" "az" {}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.aws_vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.aws_vpc_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.aws_vpc_name}-igw"
  }
}

resource "aws_subnet" "subnets" {
  vpc_id = "${aws_vpc.vpc.id}"
  count = "${length(data.aws_availability_zones.az.names)}"
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)}"
  availability_zone = "${data.aws_availability_zones.az.names[count.index]}"
  map_public_ip_on_launch = true
  tags {
    Name = "${data.aws_availability_zones.az.names[count.index]}-subnet"
  }
}

resource "aws_default_route_table" "route_table" {
    default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        Name = "${var.aws_vpc_name}-default-rt"
    }
}

resource "aws_security_group" "security_group" {
    name = "${var.aws_vpc_name}-sg"
    description = "${var.aws_vpc_name}-sg"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.aws_vpc_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }

    
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "${var.aws_vpc_name}-sg"
    }
}

output "vpc_id" { 
    value = "${aws_vpc.vpc.id}" 
}

output "vpc_cidr" { 
    value = "${aws_vpc.vpc.cidr_block}" 
}

output "vpc_igw" { 
    value = "${aws_internet_gateway.igw.id}" 
}

output "default_rt" {
    value = "${aws_default_route_table.route_table.id}"
}

