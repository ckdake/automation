locals {
  application = "test1"
  environment = "development"

  tags = {
    Application = local.application
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}
