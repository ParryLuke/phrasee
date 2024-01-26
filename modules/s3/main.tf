resource "aws_s3_bucket" "nginx_bucket" {
  bucket = var.nginx_bucket_name
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.nginx_bucket.bucket
  key    = "index.html"
  acl    = "private"

  source = "./modules/s3/index.html"
}
