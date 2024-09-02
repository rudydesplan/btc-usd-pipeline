# S3 Buckets for Data Layers
resource "aws_s3_bucket" "bronze_layer" {
  bucket = var.bronze_layer_bucket_name
}

resource "aws_s3_bucket" "silver_layer" {
  bucket = var.silver_layer_bucket_name
}

resource "aws_s3_bucket" "gold_layer" {
  bucket = var.gold_layer_bucket_name
}

# Apply versioning, encryption, and public access block to all data layer buckets
locals {
  data_layer_buckets = [
    aws_s3_bucket.bronze_layer,
    aws_s3_bucket.silver_layer,
    aws_s3_bucket.gold_layer
  ]
}

resource "aws_s3_bucket_versioning" "data_layers" {
  count  = length(local.data_layer_buckets)
  bucket = local.data_layer_buckets[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_layers" {
  count  = length(local.data_layer_buckets)
  bucket = local.data_layer_buckets[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data_layers" {
  count  = length(local.data_layer_buckets)
  bucket = local.data_layer_buckets[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policies using aws_iam_policy_document
data "aws_iam_policy_document" "bronze_layer_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.bronze_layer.arn,
      "${aws_s3_bucket.bronze_layer.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_role.msk_connect_role.arn,
        aws_iam_role.emr_service_role.arn,
        aws_iam_role.glue_role.arn,
      ]
    }
  }

  statement {
    sid       = "EnforceTLS"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.bronze_layer.arn,
      "${aws_s3_bucket.bronze_layer.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "bronze_layer_policy" {
  bucket = aws_s3_bucket.bronze_layer.id
  policy = data.aws_iam_policy_document.bronze_layer_policy.json
}

data "aws_iam_policy_document" "silver_layer_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.silver_layer.arn,
      "${aws_s3_bucket.silver_layer.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_role.emr_service_role.arn,
        aws_iam_role.glue_role.arn,
      ]
    }
  }

  statement {
    sid       = "EnforceTLS"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.silver_layer.arn,
      "${aws_s3_bucket.silver_layer.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "silver_layer_policy" {
  bucket = aws_s3_bucket.silver_layer.id
  policy = data.aws_iam_policy_document.silver_layer_policy.json
}

data "aws_iam_policy_document" "gold_layer_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.gold_layer.arn,
      "${aws_s3_bucket.gold_layer.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_role.emr_service_role.arn,
        aws_iam_role.glue_role.arn,
      ]
    }
  }

  statement {
    sid       = "EnforceTLS"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.gold_layer.arn,
      "${aws_s3_bucket.gold_layer.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "gold_layer_policy" {
  bucket = aws_s3_bucket.gold_layer.id
  policy = data.aws_iam_policy_document.gold_layer_policy.json
}
