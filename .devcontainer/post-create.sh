#!/bin/bash

set -eou pipefail

# This downloads the tflint plugins configured in .tflint.hcl
tflint --init

# infracost: Downloads the CLI based on your OS/arch and puts it in /usr/local/bin
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Sets up empty AWS Config
cp -R "/workspaces/automation/.devcontainer/config/.aws" ~/.aws