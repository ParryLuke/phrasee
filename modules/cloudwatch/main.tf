resource "aws_cloudwatch_log_group" "nginx_log_group" {
  name = var.nginx_log_group
}

resource "aws_cloudwatch_log_stream" "nginx_log_stream" {
  name           = var.nginx_log_stream
  log_group_name = aws_cloudwatch_log_group.nginx_log_group.name
}

resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  dashboard_name = "Nginx"

  dashboard_body = jsonencode({
    widgets = [
      {
            "type": "log",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 6,
            "properties": {
                "query": "SOURCE 'nginx-log-group' | fields @timestamp, @message\n| parse @message /HTTP\\/1\\.[01]\"\\s(?<statusCode>\\d{3})/\n| filter statusCode =~ /^(1\\d\\d|2\\d\\d|3\\d\\d|4\\d\\d|5\\d\\d)$/\n| stats count() by statusCode",
                "region": "eu-west-1",
                "stacked": false,
                "title": "Nginx HTTP status codes",
                "view": "bar"
            }
      },
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "${var.ec2_instance}"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "${var.region}"
          title  = "${var.ec2_instance} - CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId",
              "${var.ec2_instance}"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "${var.region}"
          title  = "${var.ec2_instance} - NetworkIn"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name                = "ec2-cpu-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization reaches 80%"
  insufficient_data_actions = []
}
