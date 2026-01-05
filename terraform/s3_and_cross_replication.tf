## AWS IAM ROLE
resource "aws_iam_role" "s3crossreplicas-role" {
  name = var.tf-s3crossreplicas-role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Effect = "Allow"
        Principal = {
            Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
    }]
  })
}

## AWS IAM Policy
resource "aws_iam_policy" "s3crossreplicas-policy" {
    name = var.tf-s3crossreplicas-policy
    policy = jsonencode({
        Version = "20212-10-17"
        Statement = [
            {
                Action = [
                    "s3:GetReplicationConfiguration",
                    "s3:ListBucket"
                ]
                Effect = "Allow"
                Resource = [
                    "${aws_s3_bucket.bucket-source.arn}"
                ]
            },
            {
                Action = [
                    "s3:GetObjectVersion",
                    "s3:GetObjectVersionAcl"
                ]
                Effect = "Allow"
                Resource = [
                    "${aws_s3_bucket.bucket-source.arn}/*"
                ]
            },
            {
                Action = [
                    "s3:ReplicateObject",
                    "s3:ReplicateDelete"
                ]
                Effect = "Allow"
                Resource = [
                    "${aws_s3_bucket.bucket-destination.arn}/*"
                ]  
            }
            ]
    })
  
}


### Attache IAM Policy to Role
resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
    role = aws_iam_role.s3crossreplicas-role.name 
    policy_arn = aws_iam_policy.s3crossreplicas-policy.arn
  
}

#######################################################################################
### Replication Destination S3
#######################################################################################

### Create S3 source bucket
resource "aws_s3_bucket" "bucket-source" {
    bucket = var.tf-bucket-destination-s3crossreplicas
    provider = aws.east-region
    force_destroy = true  
}

#resource "aws_s3_bucket_acl" "bucket-source-acl" {
#  bucket = aws_s3_bucket.bucket-source.id
#  acl    = "private"
#}

resource "aws_s3_bucket_versioning" "bucket-source-versioning" {
  bucket = aws_s3_bucket.bucket-source.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-source-public-access-block" {
  bucket = aws_s3_bucket.bucket-source.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

### Create S3 destination bucket
resource "aws_s3_bucket" "bucket-destination" {
    bucket = var.tf-bucket-destination-s3crossreplicas
    provider = aws.west-region
    force_destroy = true
}

# Ressource chnager depuis avril à supprimer
#resource "aws_s3_bucket_acl" "bucket-destination-acl" {
#  bucket = aws_s3_bucket.bucket-destination.id
#  acl    = "private"
#}

resource "aws_s3_bucket_versioning" "bucket-destination-versioning" {
  bucket = aws_s3_bucket.bucket-destination.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-destination-public-access-block" {
  bucket = aws_s3_bucket.bucket-destination.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}