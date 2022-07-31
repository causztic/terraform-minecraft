resource "aws_apigatewayv2_api" "bot" {
  name               = "Discord Bot API"
  protocol_type      = "HTTP"
  cors_configuration {
    allow_methods = ["*"]
    allow_origins = ["https://discord.com"]
  }
}

resource "aws_apigatewayv2_stage" "test" {
  api_id = aws_apigatewayv2_api.bot.id
  name   = "test"
}