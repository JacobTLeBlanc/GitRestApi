resource "aws_api_gateway_rest_api" "git" {
  name        = "git"
  description = "Rest API for GitHub"
}

#####################
# /get_repos

resource "aws_api_gateway_resource" "get_repos_resource" {
  parent_id   = aws_api_gateway_rest_api.git.id
  path_part   = local.get_repos_name
  rest_api_id = aws_api_gateway_rest_api.git.id
}

resource "aws_api_gateway_method" "get_repos_method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.get_repos_resource.id
  rest_api_id   = aws_api_gateway_rest_api.git.id
}

resource "aws_api_gateway_integration" "get_repos_integration" {
  http_method = aws_api_gateway_method.get_repos_method.http_method
  resource_id = aws_api_gateway_resource.get_repos_resource.id
  rest_api_id = aws_api_gateway_rest_api.git.id

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_repos.invoke_arn
}