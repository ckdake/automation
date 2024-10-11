locals {
  app_name = terraform.workspace == "default" ? "app-default" : terraform.workspace

  config_value_one = coalesce(
    var.config_value_one,
    try(data.terraform_remote_state.self.outputs.config_value_one, null),
    "defaultA"
  )

  config_value_two = coalesce(
    var.config_value_two,
    try(data.terraform_remote_state.self.outputs.config_value_two, null),
    "defaultB"
  )
}
