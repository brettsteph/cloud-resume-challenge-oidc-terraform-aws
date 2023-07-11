terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
  }
  backend "s3" {
    region = "us-east-1"
    bucket = "cloud-resume-challenge-oidc-terraform-aws-tfstate"
    key    = "infra.tfstate"

    dynamodb_table = "terraform-challenge-state-lock"
    encrypt        = true #ensures Terraform state will be encrypted on disk when stored in S3
  }
}


module "backend-module" {
  source = "./modules/backend"

  domain       = module.frontend-module.domain
  sub_domain   = module.frontend-module.sub_domain
  aws_acm_cert = module.frontend-module.aws_acm_cert
}

module "frontend-module" {
  source = "./modules/frontend"

  domain                      = "brettstephen.com"
  sub_domain                  = "resume.brettstephen.com"
  api_gw_domain_name          = module.backend-module.api_gw_domain_name
  api_gw_regional_domain_name = module.backend-module.api_gw_regional_domain_name
  api_gw_regional_zone_id     = module.backend-module.api_gw_regional_zone_id
}
