data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

resource "aws_security_group" "lambda" {
  name        = local.resource_name
  description = local.resource_name
  vpc_id      = data.aws_subnet.selected.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    tomap({ "Scope" = local.resource_name }),
  )
}
