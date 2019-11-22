resource "aws_iam_role" "roles" {
  name        = "my-role"
  path        = "/"
  description = "my-role description"

  # This policy defines who/what is allowed to use the current role
  assume_role_policy = "${file("policy.json")}"

  # Allow session for X seconds
  max_session_duration  = "3600"
  force_detach_policies = true

  tags = {
    Name  = "my-role"
    Owner = "terraform"
  }
}
