terraform {
  extra_arguments "common_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy",
    ]

    required_var_files = [
      "${get_terragrunt_dir()}/terraform.tfvars",
    ]

    optional_var_files = [
      "${get_terragrunt_dir()}/${find_in_parent_folders("region.tfvars")}",
    ]
  }

  extra_arguments "disable_input" {
    commands = get_terraform_commands_that_need_vars()
    arguments = ["-input=true"]
  }

  after_hook "copy_common_main_providers" {
    commands = ["init-from-module"]
    execute = ["cp", "${get_parent_terragrunt_dir()}/../_provider_include/include_providers.tf", "${get_terragrunt_dir()}"]
  }
}

remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket = "my-tg-bucket"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "my-tf-lock"
  }
}

inputs = {
  env = "dev"
  allowed_account_ids = ["123456789"]
}
