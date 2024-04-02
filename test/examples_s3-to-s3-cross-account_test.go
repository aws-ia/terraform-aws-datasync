package test

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	//	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestS3toS3CrossAccount(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/s3-to-s3-cross-account",
	}

	// Read secret from Secrets Manager
	err := updateAWSCredentials("/terratest/examples/s3-to-s3-cross-account")
	if err != nil {
		fmt.Println("Error updating AWS credentials:", err)
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

// updateAWSCredentials retrieves a secret from AWS Secrets Manager and writes its content to the .aws/credentials file.
func updateAWSCredentials(secretName string) error {
	// Load the AWS default config
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		return err
	}

	// Create a Secrets Manager client
	svc := secretsmanager.NewFromConfig(cfg)

	// Retrieve the secret value
	result, err := svc.GetSecretValue(context.TODO(), &secretsmanager.GetSecretValueInput{
		SecretId: &secretName,
	})
	if err != nil {
		return err
	}

	// Construct the path to the .aws/credentials file
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return err
	}
	credentialsPath := filepath.Join(homeDir, ".aws", "credentials")

	// Assuming the secret's content is in string format and needs to be written directly
	// Adjust as needed if the secret format differs
	secretString := ""
	if result.SecretString != nil {
		secretString = *result.SecretString
	} else {
		// Handle the case where the secret is in binary format, not covered in this example
		fmt.Println("Secret is not in string format")
		return fmt.Errorf("secret is not in string format")
	}

	// Replace spaces with newlines
	//secretString = strings.ReplaceAll(secretString, " ", "\n")

	// Write the secret's content directly to the credentials file
	return os.WriteFile(credentialsPath, []byte(secretString), 0600)
}
