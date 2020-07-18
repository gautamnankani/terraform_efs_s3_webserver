// Important: Change all the default values before running

variable "profile_name" {
    type = string
    description = "enter the profile name"
    default = "myprofile"
}

variable "region_name" {
    type = string
    description = "Enter Region"
    default = "ap-south-1"
}

variable "key_Name" {
    type = string
    description = "Enter the key name for the instance key-pair creation"
    default = "mykey" 
}

variable "public_key" {
    type = string
    description = "ppublic key location"
    default = "<public key location>"
}

variable "private_key" {
    type = string
    description = "private key location"
    default = "mykey.pem" 
}

variable "instance_Type" {
    type = string
    description = "type of ec2 instance micro, small, large and various other options"
    default = "t2.micro" 
}

variable "bucket_name" {
    type = string
    description = "Unique name for s3 bucket"
    default = "gautam191httpbucket" 
}

// Note: the below image is just as an example to show it on webseite/s3/clodfront
variable "image_loc" {
    type = string
    description = "A image location to upload it in s3"
    default = "C:/Users/gautam/Pictures/a.jpg" 
}

// Note:  Right now we don't know URL of CloudFront
// later you can update the image URL/Cloudfront URL in web pages after it launched
// Or you can create alias, and write alias name in your website code
// so image will be rendered from cloudFront
variable "website_code" {
    type = string
    description = "website code: html, php"
    default = "https://github.com/vimallinuxworld13/multicloud.git" 
}

