#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype
export GOPROXY=direct

echo "Starting Functional Tests"

cd ${PROJECT_PATH}

#********** Terratest execution **********
echo "INFO: [Terratest] Running Terratest"
echo "INFO: [Terratest] Output of environment: $(env)"
echo "INFO: [Terratest] Current user and home directory: $(whoami) ${HOME}"
echo "INFO: [Terratest] Creds file path: ${HOME}/.aws/credentials"

mkdir -p $HOME/.aws
touch $HOME/.aws/credentials
ls -l $HOME/.aws/credentials

cd test
rm -f go.mod
go mod init github.com/aws-ia/terraform-project-ephemeral 
go mod tidy
go install github.com/gruntwork-io/terratest/modules/terraform
go test -timeout 45m

yum list installed
 
echo "End of Functional Tests"