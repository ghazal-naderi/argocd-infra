resource "aws_kms_key" "environment_kms_key" {
  description         = "Used for encryption throughout"
  policy              = data.aws_iam_policy_document.environment_kms_key.json
  enable_key_rotation = true
  tags                = merge(var.default_tags, var.common_tags, var.additional_tags)
}

resource "aws_kms_alias" "kms_key_alias" {
  name          = "alias/${var.cluster_name}-kms-key"
  target_key_id = aws_kms_key.environment_kms_key.key_id
}

data "aws_iam_policy_document" "environment_kms_key" {
  statement {
    sid       = "Allow Account users To Use KMS"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/svc-terraform",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/ci-user",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSAFTExecution",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/${data.aws_region.current.name}/${one(data.aws_iam_roles.admin.names)}"
      ]
    }
  }
  statement {
    sid       = "Allow CloudWatch To Use KMS"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }

  # Required for EKS
  statement {
    sid    = "Allow service-linked role use of the CMK"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/${one(data.aws_iam_roles.autoscaling.names)}",
        aws_iam_role.eks_cluster.arn
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/${one(data.aws_iam_roles.autoscaling.names)}",
        aws_iam_role.eks_cluster.arn
      ]
    }

    actions = [
      "kms:CreateGrant"
    ]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

  }
}
