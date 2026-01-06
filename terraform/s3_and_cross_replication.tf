#######################################################################################
### IAM ROLE AND POLICY
#######################################################################################

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
    description = "Allows S3 replication between primary and secondary buckets"
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
                    "arn:aws:s3:::${aws_s3_bucket.bucket-source.bucket}/*"
                ]
            },
            {
                #Action = [
                #    "s3:GetObjectVersion",
                #    "s3:GetObjectVersionAcl",
                #    "s3:GetObjectVersionForReplication"
                #]
                Action   = [
                     "s3:ReplicateObject", 
                     "s3:ReplicateDelete", 
                     "s3:GetObjectVersion", 
                     "s3:GetObjectVersionAcl"
                ]
                Effect = "Allow"
                Resource = [
                    "arn:aws:s3:::${aws_s3_bucket.bucket-source.bucket}/*"
                ]
            },
            {
                Action = [
                    "s3:ReplicateObject",
                    "s3:ReplicateDelete"
                ]
                Effect = "Allow"
                Resource = [
                    "arn:aws:s3:::${aws_s3_bucket.bucket-destination.bucket}/*"
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
    bucket = var.tf-bucket-source-s3crossreplicas
    provider = aws.primary
    force_destroy = true  
}
### Create S3 source versioning 
resource "aws_s3_bucket_versioning" "bucket-source-versioning" {
    provider = aws.primary
    bucket = aws_s3_bucket.bucket-source.id
    versioning_configuration {
      status = "Enabled"
    }
}

### Create S3 destination bucket
resource "aws_s3_bucket" "bucket-destination" {
    bucket = var.tf-bucket-destination-s3crossreplicas
    provider = aws.secondary
    force_destroy = true
}
### Create S3 destination versioning 
resource "aws_s3_bucket_versioning" "bucket-destination-versioning" {
  bucket = aws_s3_bucket.bucket-destination.id
  provider = aws.secondary
  versioning_configuration {
    status = "Enabled"
  }
}


## Configuration of replication
resource "aws_s3_bucket_replication_configuration" "replication" {
    provider = aws.primary 
     bucket = aws_s3_bucket.bucket-source.id
     role = aws_iam_role.s3crossreplicas-role.arn

     rule {
       id = "Cross-region-replication"
       status = "Enabled"
       
       filter {
         prefix = ""
       }

       destination {
         bucket = aws_s3_bucket.bucket-destination.arn 
         storage_class = "STANDARD"
       }

       delete_marker_replication {
         status = "Enabled"
       }
     }

    depends_on = [ 
        aws_s3_bucket_versioning.bucket-destination-versioning,
        aws_s3_bucket_versioning.bucket-source-versioning
     ]
  
}