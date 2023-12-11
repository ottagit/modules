# Route traffic from the Internet to VPC
resource "aws_internet_gateway" "test-env-igw" {
  vpc_id = "${aws_vpc.test-env.id}"

  tags = {
    Name = "test-env-igw"
  }
}