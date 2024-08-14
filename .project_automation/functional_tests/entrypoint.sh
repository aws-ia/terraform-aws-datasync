#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype
export GOPROXY=direct

echo "Starting Functional Tests"

cd ${PROJECT_PATH}

#********** Terratest execution **********
echo "Running Terratest"
cd test
rm -f go.mod
/usr/local/bin/go/bin/go version
ls -la /usr/local/bin/go/bin
/usr/local/bin/go/bin/go mod init github.com/aws-ia/terraform-project-ephemeral 
/usr/local/bin/go/bin/go mod tidy
/usr/local/bin/go/bin/go install github.com/gruntwork-io/terratest/modules/terraform
/usr/local/bin/go/bin/go test -timeout 45m

echo "End of Functional Tests"