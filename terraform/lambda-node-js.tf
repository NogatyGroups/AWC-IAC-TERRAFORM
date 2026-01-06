###################################################################################
# Zip a function
###################################################################################
## Zip the function to be run at function App
data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = "${path.module}/Projet-nodejs/hello.js"
    output_path = "${path.module}/hello.zip"
}

### S3 bucket
resource "aws_s3_bucket" "nogaty-bucket-lambda" {
    bucket = "${var.lambda-bucket}-01"
    provider = aws.primary
    force_destroy = true  

    tags = {
      Name = "${var.lambda-bucket}-01"
    }
}

### Upload zip file to S3 bucket
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.nogaty-bucket-lambda.bucket
  key    = "hello.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = data.archive_file.lambda_zip.output_base64sha256
}

###################################################################################
# Create IAM role and Policy
###################################################################################
### IAM ROLE
resource "aws_iam_role" "lambda-iam-role" {
    name = var.lambda-iam-role
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Effect = "Allow"
        Principal = {
            Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
    }]
  })
}

### IAM POLICY
resource "aws_iam_policy" "lambda-iam-policy" {
    name = var.lambda-iam-policy
    description = "Allows Lambda to S3 bucket"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                   "logs:*"
                ]
                Effect = "Allow"
                Resource = "*"
            }
            ]
    })
  
}

### Attache IAM Policy to Role
resource "aws_iam_role_policy_attachment" "lambda-role-policy-attachment" {
    role = aws_iam_role.lambda-iam-role.name
    policy_arn = aws_iam_policy.lambda-iam-policy.arn
  
}

###################################################################################
# Create Lambda function
###################################################################################
resource "aws_lambda_function" "lambda-nodejs" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.lambda-nodejs-function
  role          = aws_iam_role.lambda-iam-role.arn
  handler       = "index.handler"
  code_sha256   = data.archive_file.lambda_zip.output_base64sha256

  runtime = "nodejs20.x"

  environment {
    variables = {
      ENVIRONMENT = "development"
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Environment = "development"
    Application = "lambda-nodejs-function"
  }
}

######################################################################################
# A revoir: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
#######################################################################################