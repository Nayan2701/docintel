terraform {
  backend "s3" {
    bucket       = "docintel-tfstate-nayan2701"
    key          = "bootstrap/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
