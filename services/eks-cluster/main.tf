# Create an IAM role for the control plane
resource "aws_iam_role" "cluster" {
  name = "${var.name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

# Allow EKS to assume the IAM role
data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect = "Allow"
    actions = [ "sts::AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "eks.amazonaws.com" ]
    }
  }
}

# Attach the permissions the IAM role needs
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cluster.name
}

# Only use this configuration for testing and learning. For production
# use cases, use a custom VPC and private subnet
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default]
  }
}

# Create the control plane for the EKS cluster
resource "aws_eks_cluster" "cluster" {
  name = "${var.name}"
  role_arn = aws_iam_role.cluster.arn
  version = "1.2.1"

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }

  # Ensure IAM Role permissions are created before and deleted after the EKS Cluster.connection {
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infra such as Security Groups
  depends_on = [ 
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
   ]
}
