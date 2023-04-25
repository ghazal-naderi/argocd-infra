resource "aws_ecr_repository" "platform_infra_proxy" {
  name                 = "platform/proxy/public_images"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
