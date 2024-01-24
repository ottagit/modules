# Create an EC2 instance
resource "aws_instance" "jenkins_instance" {
  ami = "${var.ami_id}"
  instance_type = "t2.medium"
  key_name = "${var.ami_key_pair_name}"
  security_groups = ["${aws_security_group.outbound_inbound_all.id}"]

  tags = {
    Name = "${var.ami_name}"
  }

  subnet_id = "${aws_subnet.ec2_subnet.id}"
  # Attach the instance profile
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance.name
}

resource "aws_eip_association" "jenkins_instance_eip" {
  instance_id = aws_instance.jenkins_instance.id
  allocation_id = aws_eip.instance_eip.id
}

# Define an assume role policy that dictates who is
# allowed to assume a given IAM role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

module "ci_server_role" {
  source = "github.com/ottagit/modules//ci-cd/global/iam/roles/ci-server?ref=v0.1.6"

  name = "jenkins-instance-role"
  dynamo_db_table   = "terraone-locks"
  s3_bucket_name    = "batoto-bitange"
  path_to_key       = "global/s3/terraformjenkins.tfstate"
  provider-name     = "token.actions.githubusercontent.com"
}

# Allow the Jenkins instance to automatically assume the
# Jenkins instance IAM role
resource "aws_iam_instance_profile" "jenkins_instance" {
  role = aws_iam_role.jenkins_instance.name
}


