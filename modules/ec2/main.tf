resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Security group for nginx EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "nginx_ec2_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "nginx_keypair" {
  key_name   = "nginx_keypair"
  public_key = tls_private_key.nginx_ec2_private_key.public_key_openssh
}

resource "aws_instance" "nginx_ec2_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  key_name = aws_key_pair.nginx_keypair.key_name

  iam_instance_profile = var.nginx_instance_profile

  provisioner "remote-exec" {
    inline = [
      # packages
      "sudo yum update -y",
      "sudo yum install -y docker awscli unzip",

      # docker
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user",
      "sudo docker run -d -p 80:80 --name nginx --log-driver=awslogs --log-opt awslogs-region=${var.region} --log-opt awslogs-group=${var.nginx_log_group} --log-opt awslogs-create-group=true --log-opt awslogs-stream=${var.nginx_log_stream} nginx:latest",

      # copy from S3
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "aws s3 cp s3://${var.nginx_bucket_name}/index.html /tmp",
      "sudo docker cp /tmp/index.html $(sudo docker ps -q):/usr/share/nginx/html/",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.nginx_ec2_private_key.private_key_pem
      host        = aws_instance.nginx_ec2_instance.public_ip
    }
  }
}
