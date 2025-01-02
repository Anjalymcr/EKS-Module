## Create ECR repository
resource "aws_ecr_repository" "wilt-frontend" {
  name = "wilt-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "wilt-backend" {
  name = "wilt-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_frontend_repository_url" {
  value = aws_ecr_repository.wilt-frontend.repository_url
}

output "ecr_backend_repository_url" {
  value = aws_ecr_repository.wilt-backend.repository_url
}