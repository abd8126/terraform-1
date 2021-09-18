resource "aws_vpc" "main" {
cidr_block = "10.0.0.0/16"
enable_dns_support = "true"
enable_dns_hostnames = "true"
}

resource "aws_subnet" "private-subnet1" {
vpc_id = "${aws_vpc.main.id}"
cidr_block = "10.0.1.0/24"
availability_zone = "ap-south-1a"
}

resource "aws_subnet" "private-subnet2" {
vpc_id = "${aws_vpc.main.id}"
cidr_block = "10.0.2.0/24"
availability_zone = "ap-south-1b"
}

resource "aws_db_subnet_group" "db-subnet" {
name = "db-subnet-group"
subnet_ids = ["${aws_subnet.private-subnet1.id}", "${aws_subnet.private-subnet2.id}"]
}

resource "aws_subnet" "public-subnet1" {
vpc_id = "${aws_vpc.main.id}"
cidr_block = "10.0.3.0/24"
availability_zone = "ap-south-1a"
}

resource "aws_subnet" "public-subnet2" {
vpc_id = "${aws_vpc.main.id}"
cidr_block = "10.0.4.0/24"
availability_zone = "ap-south-1b"
}

resource "aws_internet_gateway" "igw" {
vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "public" {
vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "private" {
vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "public_route" {
route_table_id = "${aws_route_table.public.id}"
destination_cidr_block = "0.0.0.0/0"
gateway_id = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "public1" {
subnet_id = "${aws_subnet.public-subnet1.id}"
route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public2" {
subnet_id = "${aws_subnet.public-subnet2.id}"
route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private1" {
subnet_id = "${aws_subnet.private-subnet1.id}"
route_table_id="${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private2" {
subnet_id = "${aws_subnet.private-subnet2.id}"
route_table_id="${aws_route_table.private.id}"
}

resource "aws_security_group" "default" {
name = "default-sg"
vpc_id = "${aws_vpc.main.id}"
ingress {
from_port = 22
to_port = 22
protocol = "tcp"
}
ingress {
from_port = 3306
to_port = 3306
protocol = "tcp"
}
}

resource "aws_instance" "ec2-instance" {
ami = "ami-04db49c0fb2215364"
instance_type = "t2.micro"
subnet_id = "${aws_subnet.public-subnet1.id}"
vpc_security_group_ids = ["${aws_security_group.default.id}"]
key_name = "mykey1"
}

resource "aws_db_instance" "mysql-db" {
allocated_storage = 10
identifier = "test"
engine = "mysql"
engine_version = "5.7"
instance_class = "db.t2.micro"
name = "mydb"
username = "sahil"
password = "sahil1234"
db_subnet_group_name = "${aws_db_subnet_group.db-subnet.name}"
vpc_security_group_ids = ["${aws_security_group.default.id}"]
}
