# Set up a subnet in the VPC
resource "aws_subnet" "ec2-subnet" {
  cidr_block = "${cidrsubnet(aws_vpc.test-env.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.test-env.id}"
  availability_zone = "us-east-1a"
}
# Define route table and attach IGW
resource "aws_route_table" "test-env-route-table" {
  vpc_id = "${aws_vpc.test-env.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-igw.id}"
  }

  tags = {
    Name = "test-env-route-table"
  }
}
# Associate route table with subnet
resource "aws_route_table_association" "subnet-association" {
  subnet_id = "${aws_subnet.ec2-subnet.id}"
  route_table_id = "${aws_route_table.test-env-route-table.id}"
}