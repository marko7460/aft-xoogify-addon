resource "aws_servicecatalog_principal_portfolio_association" "example" {
  portfolio_id  = var.portfolio_id
  principal_arn = module.aft_iam_roles.ct_management_exec_role_arn
  principal_type = "IAM"
}

data "google_client_config" "current" {}

resource "aws_iam_openid_connect_provider" "xoogify" {
  url             = "https://securetoken.google.com/${data.google_client_config.current.project}"
  client_id_list  = [data.google_client_config.current.project]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
    "08745487e891c19e3078c1f2a07e452950ef36f6"
  ]
  tags = {
    AddonName = "xoogify"
  }
}

data "aws_iam_policy_document" "xoogify_oidc" {
  statement {
    sid    = "XoogifyOidcAuth"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = ["${aws_iam_openid_connect_provider.xoogify.arn}/${aws_iam_openid_connect_provider.xoogify.url}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.xoogify.url}:aud"
      values   = ["${data.google_client_config.current.project}"]
    }

    dynamic "condition" {
      for_each = length(toset(var.xoogify_organizations)) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "${aws_iam_openid_connect_provider.xoogify.url}:organization"
        values   = [toset(var.xoogify_organizations)]
      }
    }

    dynamic "condition" {
      for_each = length(toset(var.xoogify_uids)) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "${aws_iam_openid_connect_provider.xoogify.url}:uid"
        values   = [toset(var.xoogify_uids)]
      }
    }

    dynamic "condition" {
      for_each = length(toset(var.xoogify_architectures)) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "${aws_iam_openid_connect_provider.xoogify.url}:architecture"
        values   = [toset(var.xoogify_architectures)]
      }
    }
  }
}

resource "aws_iam_role" "xoogify_oidc" {
  name        = var.xoogify_name
  path        = var.xoogify_path
  description = "Role that allows xoogify hyperautomation to use OIDC to authenticate users and assume AFT roles"

  assume_role_policy    = data.aws_iam_policy_document.xoogify_oidc.json
  max_session_duration  = var.xoogify_max_session_duration
  permissions_boundary  = var.xoogify_permissions_boundary_arn
  force_detach_policies = var.xoogify_force_detach_policies

  tags = {
    "Addon" = "xoogify"
  }
}

resource "aws_iam_role_policy_attachment" "xoogify-oidc-policy-attachment" {
  role       = aws_iam_role.xoogify_oidc.name
  policy_arn = aws_iam_policy.xoogify-policy.arn
}

data "aws_iam_policy_document" "xoogify-policy-definition" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::*:role/AWSAFTAdmin"]
  }
}

resource "aws_iam_policy" "xoogify-policy" {
  name        = "xoogify-aft-hyperautomation-policy"
  description = "Policy used by xoogify automation for admin access"
  policy      = data.aws_iam_policy_document.xoogify-policy-definition.json
}

output "xoogify_hyperautomation_role_arn" {
  description = "The ARN of the role that allows xoogify hyperautomation to use OIDC to authenticate users and assume AFT roles"
  value       = aws_iam_role.xoogify_oidc.arn
}