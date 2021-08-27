provider "aws" {
  profile = "default"
  region = "us-east-1"
}

resource "aws_s3_bucket" "aruna_tf" {
   bucket = "aruna004"
   acl = "private"
}  
   