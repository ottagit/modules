output "user_arn" {
  value = aws_iam_user.example.arn
  description = "The ARN of the created IAM user"
}

output "all_users" {
  value = aws_iam_user.example
  description = "The created IAM users"
}