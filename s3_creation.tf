///////////////////////////////////////////////////////////// S3_BUCKET AND CLOUDFRONT
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  acl    = "private"
  force_destroy = true     // danger not usally used in company
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

// adding image to s3 bucket
// change image path to the path of image in your system 
resource "aws_s3_bucket_object" "my_bucket_object" {
  key    = "image.png"
  acl    = "private"
  bucket =  aws_s3_bucket.my_bucket.id
  source =  var.image_loc
  content_type = "image or jpeg"
  depends_on = [
     aws_s3_bucket.my_bucket
  ]
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.my_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.my_bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [ aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn ]
    }
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
