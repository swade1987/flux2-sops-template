# =======================================================================================
# This is the role that the flux-secrets pod needs to assume.
# =======================================================================================
resource "aws_iam_role" "flux_secrets_assume" {
  name                  = "flux-secrets-assume-${data.aws_region.current.name}"
  assume_role_policy    = data.aws_iam_policy_document.flux_secrets_assume_assume.json
  force_detach_policies = "true"
}

data "aws_iam_policy_document" "flux_secrets_assume_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }

    principals {
      identifiers = [aws_iam_role.kiam_server_role.arn]
      type        = "AWS"
    }
  }
}
