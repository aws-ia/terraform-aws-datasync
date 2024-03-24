package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestS3toS3(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/s3-to-s3",
		// Vars: map[string]interface{}{
		// 	"myvar":     "test",
		// 	"mylistvar": []string{"list_item_1"},
		// },
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
