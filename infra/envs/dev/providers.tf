provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project     = "docintel"
      environment = "dev"
      managed_by  = "terraform"
    }
  }
}
