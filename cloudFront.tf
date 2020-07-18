resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "creation of origin access identity"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name    =   aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id      =   aws_s3_bucket.my_bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true

  default_cache_behavior {
    allowed_methods     =  ["GET", "HEAD"]
    cached_methods      =  ["GET", "HEAD"]
    forwarded_values {
      query_string      =  false
      cookies {
        forward         =  "none"
      }
    }
    target_origin_id        =  aws_s3_bucket.my_bucket.id
    viewer_protocol_policy  =  "redirect-to-https"
  }
  restrictions {
     geo_restriction {
          restriction_type  =  "none"
     }
  }

  viewer_certificate {
    cloudfront_default_certificate   =  true
  }  
  depends_on = [
     aws_s3_bucket.my_bucket
  ]
}
