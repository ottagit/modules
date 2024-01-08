# Route traffic from the Internet to VPC
resource "aws_internet_gateway" "test_env_igw" {
  vpc_id = "${aws_vpc.test_env.id}"

  tags = {
    Name = "test-env-igw"
  }
}