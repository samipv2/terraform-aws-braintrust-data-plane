locals {
  clickhouse_bucket_name = var.external_clickhouse_s3_bucket_name == null ? aws_s3_bucket.clickhouse_s3_bucket[0].id : var.external_clickhouse_s3_bucket_name
}

data "aws_region" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_subnet" "clickhouse_subnet" {
  id = var.clickhouse_subnet_id
}

resource "aws_launch_template" "clickhouse" {
  count         = var.clickhouse_instance_count
  name          = "${var.deployment_name}-clickhouse"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.clickhouse_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.clickhouse.name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    delete_on_termination = true
    security_groups       = var.clickhouse_security_group_ids
    subnet_id             = var.clickhouse_subnet_id
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 128
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.kms_key_arn
      delete_on_termination = true
    }
  }

  key_name = var.clickhouse_instance_key_pair_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    aws_region           = data.aws_region.current.name
    s3_bucket_name       = local.clickhouse_bucket_name
    clickhouse_secret_id = aws_secretsmanager_secret.clickhouse_secret.id
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.deployment_name}-clickhouse"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.deployment_name}-clickhouse"
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      Name = "${var.deployment_name}-clickhouse"
    }
  }
}

resource "aws_instance" "clickhouse" {
  count = var.clickhouse_instance_count
  launch_template {
    id      = aws_launch_template.clickhouse[0].id
    version = "$Latest"
  }
}

# EBS volume for Clickhouse metadata. This needs to be preserved across instances.
resource "aws_ebs_volume" "clickhouse_metadata" {
  count             = var.clickhouse_instance_count
  availability_zone = data.aws_subnet.clickhouse_subnet.availability_zone
  size              = var.clickhouse_metadata_storage_size
  type              = "gp3"
  encrypted         = true
  kms_key_id        = var.kms_key_arn

  tags = {
    Name = "${var.deployment_name}-clickhouse-metadata"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "clickhouse_metadata" {
  count       = var.clickhouse_instance_count
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.clickhouse_metadata[0].id
  instance_id = aws_instance.clickhouse[0].id

  # This is a workaround to ensure the volume is attached after the instance is created.
  depends_on = [aws_instance.clickhouse]
}
