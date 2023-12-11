# Create a non-default VPC
resource "aws_vpc" "test-env" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "test-env"
  }
}
# Attach public IP to instance
resource "aws_eip" "instance-eip" {
  instance = "${aws_instance.jenkins-instance.id}"
  domain = "vpc"
}