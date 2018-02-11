provider "aws" {
  region     = "${var.aws_region_a}"
}

provider "aws" {
  alias = "peer"
  region = "${var.aws_region_b}"

  # Accepter's credentials.
}


module "aws_vpc_a" "aws_region_a" {
    source = "./terraform-aws-vpc"
    aws_region = "${var.aws_region_a}"
    aws_vpc_name = "${var.aws_vpc_region_a}"
    aws_vpc_cidr = "${var.aws_vpc_cidr_a}"
}

module "aws_vpc_b" "aws_region_b" {
    source = "./terraform-aws-vpc"
    aws_region = "${var.aws_region_b}"
    aws_vpc_name = "${var.aws_vpc_region_b}"
    aws_vpc_cidr = "${var.aws_vpc_cidr_b}"
}

resource "aws_vpc_peering_connection" "requester" {
  vpc_id        = "${module.aws_vpc_a.vpc_id}"
  peer_vpc_id   = "${module.aws_vpc_b.vpc_id}"
  peer_region   = "${var.aws_region_b}"
  auto_accept   = false

  tags {
    Name = "VPC Peering between ${var.aws_vpc_region_a}  and ${var.aws_vpc_region_b}"
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = "aws.peer"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester.id}"
  auto_accept               = true

  tags {
    Name = "VPC Peering between ${var.aws_vpc_region_a}  and ${var.aws_vpc_region_b}"
    Side = "Accepter"
  }
}

resource "aws_route_table" "rt_a" {
    vpc_id = "${module.aws_vpc_a.vpc_id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${module.aws_vpc_a.vpc_igw}"
    }

    route {
        cidr_block = "${module.aws_vpc_b.vpc_cidr}"
        gateway_id = "${aws_vpc_peering_connection.requester.id}"
    }

    tags {
        Name = "VPC Peering between ${var.aws_vpc_region_a}  and ${var.aws_vpc_region_b}"
    }
}

resource "aws_route_table" "rt_b" {
    provider = "aws.peer"
    vpc_id = "${module.aws_vpc_b.vpc_id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${module.aws_vpc_b.vpc_igw}"
    }

    route {
        cidr_block = "${module.aws_vpc_a.vpc_cidr}"
        gateway_id = "${aws_vpc_peering_connection.requester.id}"
    }

    tags {
        Name = "VPC Peering between ${var.aws_vpc_region_a}  and ${var.aws_vpc_region_b}"
    }
}

resource "aws_main_route_table_association" "main_rt_a" {
  vpc_id         = "${module.aws_vpc_a.vpc_id}"
  route_table_id = "${aws_route_table.rt_a.id}"
}

resource "aws_main_route_table_association" "main_rt_b" {
  provider = "aws.peer"
  vpc_id         = "${module.aws_vpc_b.vpc_id}"
  route_table_id = "${aws_route_table.rt_b.id}"
}

resource "aws_security_group" "security_group_a" {
    name = "VPC Peering between ${var.aws_vpc_region_a}  and ${var.aws_vpc_region_b}"
    description = "VPC Peering between ${var.aws_vpc_region_a}  and ${var.aws_vpc_region_b}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${module.aws_vpc_b.vpc_cidr}"]
    }
    
    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }

    
    vpc_id = "${module.aws_vpc_a.vpc_id}"

}

resource "aws_security_group" "security_group_b" {
    provider = "aws.peer"
    name = "VPC Peering between ${var.aws_vpc_region_a}  and ${var.aws_vpc_region_b}"
    description = "VPC Peering between ${var.aws_vpc_region_a}  and ${var.aws_vpc_region_b}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${module.aws_vpc_a.vpc_cidr}"]
    }
    
    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }

    
    vpc_id = "${module.aws_vpc_b.vpc_id}"

}
