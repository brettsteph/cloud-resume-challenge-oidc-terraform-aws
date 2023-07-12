terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
  }
  backend "s3" {}
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
