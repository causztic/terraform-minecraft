resource "aws_apigatewayv2_api" "bot" {
  name               = "Discord Bot API"
  protocol_type      = "HTTP"
  cors_configuration = {
    allow_methods = "POST"
    allow_origins = "https://discord.com"
  }
}