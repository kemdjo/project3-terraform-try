
provider "aws" {

    region = "us-east-1"
   
 }

resource "aws_dynamodb_table" "userseverless" {
  name           = "userseverless"
  billing_mode = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "userseverless"
    Environment = "production"
  }
}

resource "aws_iam_role_policy" "general-api-policy" {
  name = "general-api-policy"
  role = aws_iam_role.serverless-api-role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "serverless-api-role" {
  name = "serverless-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "output/lambda_function.zip"
}

resource "aws_lambda_function" "serverless-api-lambda" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "output/lambda_function.zip"
  function_name = "serverless-api-lambda"
  role          = aws_iam_role.serverless-api-role.arn
  handler       = "lambda_function.lambda_handler"
  

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("output/lambda_function.zip"))}"
  source_code_hash = "${filebase64sha256("output/lambda_function.zip")}"

  runtime = "python3.9"

}
//API-getway
resource "aws_api_gateway_rest_api" "my-api" {
  name = "my-api"
}

//health
resource "aws_api_gateway_resource" "health" {
  parent_id   = aws_api_gateway_rest_api.my-api.root_resource_id
  path_part   = "health"
  rest_api_id = aws_api_gateway_rest_api.my-api.id
}

resource "aws_api_gateway_method" "h-get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.health.id
  rest_api_id   = aws_api_gateway_rest_api.my-api.id
}

resource "aws_api_gateway_integration" "h-get-intergartion" {
  http_method = aws_api_gateway_method.h-get.http_method
  resource_id = aws_api_gateway_resource.health.id
  rest_api_id = aws_api_gateway_rest_api.my-api.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.serverless-api-lambda.invoke_arn
}


//users


resource "aws_api_gateway_resource" "users" {
  parent_id   = aws_api_gateway_rest_api.my-api.root_resource_id
  path_part   = "users"
  rest_api_id = aws_api_gateway_rest_api.my-api.id
}

resource "aws_api_gateway_method" "us-get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.users.id
  rest_api_id   = aws_api_gateway_rest_api.my-api.id
}

resource "aws_api_gateway_integration" "us-get-intergartion" {
  http_method = aws_api_gateway_method.us-get.http_method
  resource_id = aws_api_gateway_resource.users.id
  rest_api_id = aws_api_gateway_rest_api.my-api.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.serverless-api-lambda.invoke_arn
}

#user
resource "aws_api_gateway_resource" "user" {
  parent_id   = aws_api_gateway_rest_api.my-api.root_resource_id
  path_part   = "user"
  rest_api_id = aws_api_gateway_rest_api.my-api.id
}

resource "aws_api_gateway_method" "u-get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.user.id
  rest_api_id   = aws_api_gateway_rest_api.my-api.id
}

resource "aws_api_gateway_integration" "u-get-intergartion" {
  http_method = aws_api_gateway_method.u-get.http_method
  resource_id = aws_api_gateway_resource.user.id
  rest_api_id = aws_api_gateway_rest_api.my-api.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.serverless-api-lambda.invoke_arn
}


resource "aws_api_gateway_method" "u-put" {
  authorization = "NONE"
  http_method   = "PUT"
  resource_id   = aws_api_gateway_resource.user.id
  rest_api_id   = aws_api_gateway_rest_api.my-api.id
}

resource "aws_api_gateway_integration" "u-put-intergartion" {
  http_method = aws_api_gateway_method.u-put.http_method
  resource_id = aws_api_gateway_resource.user.id
  rest_api_id = aws_api_gateway_rest_api.my-api.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.serverless-api-lambda.invoke_arn
}


resource "aws_api_gateway_method" "u-post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.user.id
  rest_api_id   = aws_api_gateway_rest_api.my-api.id
}

resource "aws_api_gateway_integration" "u-post-intergartion" {
  http_method = aws_api_gateway_method.u-post.http_method
  resource_id = aws_api_gateway_resource.user.id
  rest_api_id = aws_api_gateway_rest_api.my-api.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.serverless-api-lambda.invoke_arn
}


resource "aws_api_gateway_method" "u-delete" {
  authorization = "NONE"
  http_method   = "DELETE"
  resource_id   = aws_api_gateway_resource.user.id
  rest_api_id   = aws_api_gateway_rest_api.my-api.id
}

resource "aws_api_gateway_integration" "u-delete-intergartion" {
  http_method = aws_api_gateway_method.u-delete.http_method
  resource_id = aws_api_gateway_resource.user.id
  rest_api_id = aws_api_gateway_rest_api.my-api.id
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.serverless-api-lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.serverless-api-lambda.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.my-api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deploy1" {
  rest_api_id = aws_api_gateway_rest_api.my-api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.health.id,
      aws_api_gateway_method.h-get.id,
      aws_api_gateway_integration.h-get-intergartion.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.deploy1.id
  rest_api_id   = aws_api_gateway_rest_api.my-api.id
  stage_name    = "register"
}

resource "aws_cloudwatch_log_group" "lam-log-group" {
  name = "/aws/lambda/${aws_lambda_function.serverless-api-lambda.function_name}"

  retention_in_days = 14
}

resource "aws_s3_bucket" "web-school-100" {
  bucket = "web-school-100"

  tags = {
    Name        = "web-school-100"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "pr-acl" {
  bucket = aws_s3_bucket.web-school-100.id
  acl    = "private"
}


resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket = aws_s3_bucket.web-school-100.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  #routing_rule {
   # condition {
   #   key_prefix_equals = "docs/"
   # }
   # redirect {
   #   replace_key_prefix_with = "documents/"
   # }
 # }
}







resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.web-school-100.id

}



resource "aws_s3_bucket_policy" "s3-pol" {
  bucket = aws_s3_bucket.web-school-100.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::web-school-100/*"
    
    }
  ]
}
POLICY
}


# resource "aws_route53_zone" "zone1" {
#   name = "motsebo-aws.cf"
# }

# resource "aws_route53_record" "record1" {
#   allow_overwrite = true
#   name            = "motsebo-aws.cf"
#   ttl             = 30
#   type            = "NS"
#   zone_id         = aws_route53_zone.zone1.zone_id

#   records = [
#     aws_route53_zone.zone1.name_servers[0],
#     aws_route53_zone.zone1.name_servers[1],
#     aws_route53_zone.zone1.name_servers[2],
#     aws_route53_zone.zone1.name_servers[3],
#   ]
# }


# resource "aws_s3_bucket" "b" {
#   bucket = "mybucket"

#   tags = {
#     Name = "My bucket"
#   }
# }

# resource "aws_s3_bucket_acl" "b_acl" {
#   bucket = aws_s3_bucket.b.id
#   acl    = "private"
# }

# locals {
#   s3_origin_id = "myS3Origin"
# }

# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name = aws_s3_bucket.web-school-100.bucket_regional_domain_name
#     origin_id   = local.s3_origin_id

#     s3_origin_config {
#       origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
#     }
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "No comment"
#   default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "mylogs.s3.amazonaws.com"
#     prefix          = "myprefix"
#   }

#   aliases = ["motsebo-aws.cf", "motsebo-aws.cf"]

#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "allow-all"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   # Cache behavior with precedence 0
#   ordered_cache_behavior {
#     path_pattern     = "/content/immutable/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false
#       headers      = ["Origin"]

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 86400
#     max_ttl                = 31536000
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   # Cache behavior with precedence 1
#   ordered_cache_behavior {
#     path_pattern     = "/content/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   price_class = "PriceClass_200"

#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["US", "CA", "GB", "DE"]
#     }
#   }

#   tags = {
#     Environment = "production"
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
# }