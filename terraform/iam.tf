resource "aws_iam_role" "client_ssm" {
  name = "${var.project_name}-client-ssm-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Name    = "${var.project_name}-client-ssm-role"
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "client_ssm_core" {
  role       = aws_iam_role.client_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

