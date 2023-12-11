# Create an EC2 instance
resource "aws_instance" "jenkins-instance" {
  ami = "${var.ami_id}"
  instance_type = "t2.medium"
  key_name = "${var.ami_key_pair_name}"
  security_groups = ["${aws_security_group.outbound-inbound-all.id}"]

  tags = {
    Name = "${var.ami_name}"
  }

  subnet_id = "${aws_subnet.ec2-subnet.id}"
}

resource "aws_eip_association" "jenkins-instance-eip" {
  instance_id = aws_instance.jenkins-instance.id
  allocation_id = aws_eip.instance-eip.id
}