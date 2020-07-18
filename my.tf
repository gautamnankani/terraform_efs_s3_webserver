provider "aws" {
  region  =  "ap-south-1"
  profile =  "myprofile"
}

///////////////////////////////////////////////////////////// S3_BUCKET AND CLOUDFRONT
resource "aws_s3_bucket" "my_bucket" {
  bucket = "gautam191httpbucket"
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
  source =  "C:/Users/gauta/Pictures/a.jpg"
  content_type = "image or jpeg"
  depends_on = [
     aws_s3_bucket.my_bucket
  ]
}


resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "creation of origin access identity"
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


/////////////////////////////////////////////////////////////////// EC2_INSTANCE AND EFS

// security group creation
resource "aws_security_group" "my_sec" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
	  description = "NFS"
	  from_port   = 2049
	  to_port     = 2049
	  protocol    = "tcp"
	  cidr_blocks = ["0.0.0.0/0"]
	}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

// variable for image_id
variable "image_id" {
  type = string
  default  =  "ami-0447a12f28fddb066"
}


//key creation
resource "aws_key_pair" "deployer" {
  key_name   = "deploy_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgvRL0cQ9bBfZdUtW6el8tVXwWluVhVHjEGSFUZtD/8s7gnB2f1joeNmYQSmpoRylp2/Oyx8ooLOXEv4HcnwSYx3bmopHPNLI9OTSDoKzWTi9tZ8NnWqX4DzlFIrxtAY3I1kqDbTsiL4oftcv0CLGR6x/b+S/sru5Prjj/va6+hA/0U9DaIn5ZLlspX9XjpGKmeKt06p4DnFQ0ZU55s1hjuHAxqUBmDpVNhpxczdWkLSNHh/KYg3kCS1nHpB/+ov5P8FKUlcqHzAlZ3sS882mqtaByWXzUJfiqMVBpUNPJmGaL/TkqitE9EYpnx+KqvjFT7n8aKD87B9zNC0e4SnSt root@localhost.localdomain"
}

// instace creation using above image id
resource "aws_instance" "myin" {
  ami           = var.image_id
  instance_type = "t2.micro"
  security_groups = [ aws_security_group.my_sec.name ]
  key_name =  "mykey"
  tags = {
    Name = "os2"
  }
  depends_on = [
    aws_key_pair.deployer,
    aws_security_group.my_sec,
  ]
}

//Editing begins
/////////////////////////////////
// efs volume creation 
resource "aws_efs_file_system" "myvol" {
  creation_token = "my-efs"
  tags = {
    Name = "new_vol"
  }
}

//  availability_zone = aws_instance.myin.availability_zone


// attaching above efs volume and instance
resource "aws_efs_mount_target" "efs_att" {
  file_system_id = aws_efs_file_system.myvol.id
  subnet_id      = aws_instance.myin.subnet_id
  security_groups = [ aws_security_group.my_sec.id ]
}



resource "null_resource" "examle1"{
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("mykey.pem")
    host     = aws_instance.myin.public_ip
  }
  provisioner "remote-exec"{
    inline = [
        "sudo yum install amazon-efs-utils nfs-utils httpd php git -y",
        "sudo systemctl restart httpd",
        "sudo systemctl enable httpd",
        "sudo mount -t efs ${aws_efs_file_system.myvol.id}:/ /var/www/html",
        "sudo echo '${aws_efs_file_system.myvol.id}:/ /var/www/html efs defaults,_netdev 0 0' >> /etc/fstab",
        "sudo rm -rf /var/www/html/*",
        "sudo git clone https://github.com/vimallinuxworld13/multicloud.git /var/www/html/",
    ]  
  }
  depends_on = [
     aws_efs_mount_target.efs_att
  ]
}
