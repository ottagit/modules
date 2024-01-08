resource "aws_security_group" "outbound_inbound_all" {
  name = "allow-all-sg"

  vpc_id = "${aws_vpc.test_env.id}"
  # Allow all inbound traffic
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  # Allow inbound traffic on port 8080
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
  }
  # Allow inbound traffic on port 4444
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 4444
    to_port = 4444
    protocol = "tcp"
  }

  # Allow inbound traffic on port 3000
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
  }

  # Allow inbound traffic on port 5000
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
  }
  
  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}