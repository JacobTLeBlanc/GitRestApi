#####################
# Get Repos Lambda

data "aws_iam_policy_document" "assume_role_lambda_policy" {
  statement {
    sid = "lambdaAssumeRolePolicy"

    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "get_repos_role" {
  name = "GetReposRole"

  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda_policy.json
}

locals {
  get_repos_name = "get_repos"
}

data "archive_file" "get_repos_archive_file" {
  type = "zip"

  source_file = "${path.module}/lambdas/${local.get_repos_name}.py"
  output_path = "${path.module}/${local.get_repos_name}.zip"
}

resource "aws_lambda_function" "get_repos" {
  filename      = "${local.get_repos_name}.zip"
  function_name = local.get_repos_name
  handler       = "${local.get_repos_name}.lambda_handler"
  role          = aws_iam_role.get_repos_role.arn

  environment {
    variables = {
      USER = var.git_user
    }
  }

  runtime          = "python3.9"
  source_code_hash = data.archive_file.get_repos_archive_file.output_base64sha256
}

resource "aws_cloudwatch_log_group" "get_repos_log_group" {
  name = "/aws/lambda/${aws_lambda_function.get_repos.function_name}"

  retention_in_days = var.log_retention_in_days
}

data "aws_iam_policy_document" "get_repos_policy_document" {
  statement {
    sid = "GetReposPolicy"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.get_repos_log_group.arn,
      "${aws_cloudwatch_log_group.get_repos_log_group.arn}*"
    ]
  }
}

resource "aws_iam_role_policy" "get_repos_role_policy" {
  policy = data.aws_iam_policy_document.get_repos_policy_document.json
  role   = aws_iam_role.get_repos_role.id
}

resource "aws_lambda_permission" "apigw_get_repos" {
  statement_id  = "AllowExecutionFromAPIGatewayGetRepos"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_repos.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.git.id}/*/${aws_api_gateway_method.get_repos_method.http_method}${aws_api_gateway_resource.get_repos_user_resource.path}"
}
