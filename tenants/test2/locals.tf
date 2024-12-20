locals {
  application = "test2"
  environment = "development"

  tags = {
    Application = local.application
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}
