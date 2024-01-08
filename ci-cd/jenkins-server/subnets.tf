# Set up a subnet in the VPC
resource "aws_subnet" "ec2_subnet" {
  cidr_block = "${cidrsubnet(aws_vpc.test_env.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.test_env.id}"
  availability_zone = "us-east-1a"
}
# Define route table and attach IGW
resource "aws_route_table" "test_env_route_table" {
  vpc_id = "${aws_vpc.test_env.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test_env_igw.id}"
  }

  tags = {
    Name = "test-env-route-table"
  }
}
# Associate route table with subnet
resource "aws_route_table_association" "subnet_association" {
  subnet_id = "${aws_subnet.ec2_subnet.id}"
  route_table_id = "${aws_route_table.test_env_route_table.id}"
}