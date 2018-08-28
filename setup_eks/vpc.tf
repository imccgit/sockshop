#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "acm" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "terraform-eks-acm-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "acm" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.acm.id}"

  tags = "${
    map(
     "Name", "terraform-eks-acm-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "acm" {
  vpc_id = "${aws_vpc.acm.id}"

  tags {
    Name = "terraform-eks-acm"
  }
}

resource "aws_route_table" "acm" {
  vpc_id = "${aws_vpc.acm.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.acm.id}"
  }
}

resource "aws_route_table_association" "acm" {
  count = 2

  subnet_id      = "${aws_subnet.acm.*.id[count.index]}"
  route_table_id = "${aws_route_table.acm.id}"
}
