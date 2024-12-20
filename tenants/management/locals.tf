locals {
  application = "management"
  environment = "internal"

  tags = {
    Application = local.application
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}
