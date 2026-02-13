data "aws_ecr_repository" "services" {
  for_each = toset(var.repository_names)
  name     = each.value
}

resource "aws_ecr_lifecycle_policy" "services" {
  for_each = data.aws_ecr_repository.services

  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = ["latest"]
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
