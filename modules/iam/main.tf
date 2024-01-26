resource "aws_iam_role" "nginx_ec2_role" {
  name               = var.nginx_ec2_role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "nginx_ec2_s3_access_policy" {
  name        = "s3-access-policy"
  description = "Policy for EC2 instance to access S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:HeadObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.nginx_bucket_name}",
        "arn:aws:s3:::${var.nginx_bucket_name}/*"
      ]
    }
  ]
}
EOF
}

# Read only access for EC2 to S3
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  policy_arn = aws_iam_policy.nginx_ec2_s3_access_policy.arn
  role       = aws_iam_role.nginx_ec2_role.name
}

resource "aws_iam_instance_profile" "nginx_instance_profile" {
  name = var.nginx_instance_profile
  role = aws_iam_role.nginx_ec2_role.name
}

resource "aws_iam_policy" "nginx_ec2_cw_access_policy" {
  name        = "nginx-cloudwatch-access-policy"
  description = "Policy for EC2 instance to push to Cloudwatch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cw_policy_attachment" {
  policy_arn = aws_iam_policy.nginx_ec2_cw_access_policy.arn
  role       = aws_iam_role.nginx_ec2_role.name
}
