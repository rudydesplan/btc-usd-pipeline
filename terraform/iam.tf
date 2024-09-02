# IAM Roles
resource "aws_iam_role" "ecs_execution_role" {
  name               = var.ecs_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = var.ecs_task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role" "emr_service_role" {
  name               = var.emr_service_role_name
  assume_role_policy = data.aws_iam_policy_document.emr_assume_role_policy.json
}

resource "aws_iam_role" "glue_role" {
  name               = var.glue_role_name
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy.json
}

resource "aws_iam_role" "msk_connect_role" {
  name               = var.msk_connect_role_name
  assume_role_policy = data.aws_iam_policy_document.msk_connect_assume_role_policy.json
}

# IAM Policy Documents
data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "emr_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "glue_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "msk_connect_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["kafkaconnect.amazonaws.com"]
    }
  }
}

# IAM Policies
data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kafka:DescribeCluster",
      "kafka:GetBootstrapBrokers",
      "kafka:DescribeTopic",
      "kafka:ReadData",
      "kafka:WriteData"
    ]
    resources = [aws_msk_cluster.btc_usd_cluster.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.btc_usd_logs.arn}:*"]
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = var.ecs_task_policy_name
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

data "aws_iam_policy_document" "msk_connect_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kafka:DescribeCluster",
      "kafka:GetBootstrapBrokers",
      "kafka:DescribeTopic",
      "kafka:ReadData"
    ]
    resources = [aws_msk_cluster.btc_usd_cluster.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.bronze_layer.arn,
      "${aws_s3_bucket.bronze_layer.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "msk_connect_policy" {
  name   = var.msk_connect_policy_name
  policy = data.aws_iam_policy_document.msk_connect_policy.json
}

data "aws_iam_policy_document" "emr_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kafka:DescribeCluster",
      "kafka:GetBootstrapBrokers",
      "kafka:DescribeTopic",
      "kafka:ReadData"
    ]
    resources = [aws_msk_cluster.btc_usd_cluster.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.bronze_layer.arn,
      "${aws_s3_bucket.bronze_layer.arn}/*",
      aws_s3_bucket.silver_layer.arn,
      "${aws_s3_bucket.silver_layer.arn}/*",
      aws_s3_bucket.gold_layer.arn,
      "${aws_s3_bucket.gold_layer.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "emr_policy" {
  name   = var.emr_policy_name
  policy = data.aws_iam_policy_document.emr_policy.json
}

data "aws_iam_policy_document" "glue_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.bronze_layer.arn,
      "${aws_s3_bucket.bronze_layer.arn}/*",
      aws_s3_bucket.silver_layer.arn,
      "${aws_s3_bucket.silver_layer.arn}/*",
      aws_s3_bucket.gold_layer.arn,
      "${aws_s3_bucket.gold_layer.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "glue:CreateDatabase",
      "glue:CreateTable",
      "glue:UpdateTable"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "glue_policy" {
  name   = var.glue_policy_name
  policy = data.aws_iam_policy_document.glue_policy.json
}

# IAM Policy Attachments
resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

resource "aws_iam_role_policy_attachment" "msk_connect_policy_attachment" {
  role       = aws_iam_role.msk_connect_role.name
  policy_arn = aws_iam_policy.msk_connect_policy.arn
}

resource "aws_iam_role_policy_attachment" "emr_policy_attachment" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = aws_iam_policy.emr_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}
