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

# Create an IAM role and pass it the JSON from the assume_role
# policy document to use as the assume role policy
resource "aws_iam_role" "jenkins_instance" {
  name_prefix = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Define policies to attach to the Jenkins instance IAM role
data "aws_iam_policy_document" "jenkins_instance_admin_permissions" {
  statement {
    effect = "Allow"
    actions = ["ec2:*", "s3:*",]
    resources = ["*"]
  }

  statement {
    sid = "StateLockTable"

    effect = "Allow"
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:Update*",
      "dynamodb:PutItem",
    ]
    resources = [ "arn:aws:dynamodb:*:*:table/${var.dynamo_db_table}" ]
  }
}

# Attach EC2 admin policies to Jenkins IAM role
resource "aws_iam_role_policy" "jenkins_instance" {
  role = aws_iam_role.jenkins_instance.id
  policy = data.aws_iam_policy_document.jenkins_instance_admin_permissions.json
}

# Allow the Jenkins instance to automatically assume the
# Jenkins instance IAM role
resource "aws_iam_instance_profile" "jenkins_instance" {
  role = aws_iam_role.jenkins_instance.name
}

