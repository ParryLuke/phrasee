output "ec2_instance" {
    value = aws_instance.nginx_ec2_instance.id
}
