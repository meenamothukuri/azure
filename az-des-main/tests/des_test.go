package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {
	terraformDir := "../examples"

	// Define the expected values for the outputs
    expectedDesId := "/subscriptions/b665dde9-99ce-4dfe-980a-60aa599d2129/resourceGroups/azgw-poc-rg-40b01000-dev-01/providers/Microsoft.Compute/diskEncryptionSets/azgw-poc-des-40b01000-dev-01"
    expectedKvkId := "https://azgwpockv40b01000dev01.vault.azure.net/keys/azgw-poc-kvk-40b01000-dev-01/7a798a0911484b938ab435e5020fcb49"

	// Define the Terraform options to use when running the test
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,
	})

	// Cleanup resources after the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform code 
	terraform.InitAndApply(t, terraformOptions)

	// Get the actual output values from the Terraform state
	actualDesId := terraform.Output(t, terraformOptions, "des_id")
	actualKvkId := terraform.Output(t, terraformOptions, "kvk_id")

	// Assert that the actual values match the expected values
	assert.Equal(t, expectedDesId, actualDesId)
	assert.Equal(t, expectedKvkId, actualKvkId)
}
