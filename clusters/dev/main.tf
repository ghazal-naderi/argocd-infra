locals {
  common_tags = {
    "business_unit" : "lodestar"
    "application" : "middleoffice"
    "Environment" : "dev",
    "CostCenter" : "00000",
    "map-migrated" : "mig47308"
  }
}

# module "contino-dev-001" {
#   source      = "./contino-dev-001"
#   common_tags = local.common_tags
# }
