# =======================================================================================
# We need to create a role which users can assume
# This role will be used to encrypt secrets using SOPs (https://github.com/getsops/sops)
# =======================================================================================
resource "aws_iam_role" "flux_secrets" {
  name                  = "flux-secrets-${data.aws_region.current.name}"
  assume_role_policy    = data.aws_iam_policy_document.flux_secrets_assume.json
  force_detach_policies = "true"
}

data "aws_iam_policy_document" "flux_secrets_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }

    principals {
      identifiers = [aws_iam_role.flux_secrets_assume.arn]
      type        = "AWS"
    }

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_organizations_organization.this.master_account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${var.users_account_id}:root",
      ]
    }
  }
}

data "aws_iam_policy_document" "flux_secrets_full_kms" {
  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]

    effect    = "Allow"
    resources = [data.terraform_remote_state.keypairs.outputs.flux_secrets_kms_arn]
  }
}

resource "aws_iam_policy" "flux_secrets_full_kms" {
  name   = "flux-secrets-full-kms-to-key-${data.aws_region.current.name}"
  path   = "/"
  policy = data.aws_iam_policy_document.flux_secrets_full_kms.json
}

resource "aws_iam_role_policy_attachment" "flux_secrets_full_kms" {
  policy_arn = aws_iam_policy.flux_secrets_full_kms.arn
  role       = aws_iam_role.flux_secrets.id
}
