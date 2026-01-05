##############################################################################################
# S3 Bucket
##############################################################################################

output "state_bucket_id" {
  value = aws_s3_bucket.state.id
}

output "state_kucket_region" {
  value = aws_s3_bucket.state.region
}