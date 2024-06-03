package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {
	terraformDir := "../examples"

	// Define the expected values for the outputs
    expectedDaId := "/subscriptions/b665dde9-99ce-4dfe-980a-60aa599d2129/resourceGroups/azgw-poc-rg-40b01000-dev-01/providers/Microsoft.Compute/diskAccesses/azgw-poc-da-40b01000-dev-01"
    expectedStId := "/subscriptions/b665dde9-99ce-4dfe-980a-60aa599d2129/resourceGroups/azgw-poc-rg-40b01000-dev-01/providers/Microsoft.Storage/storageAccounts/azgwpocst40b01000dev01"


	// Define the Terraform options to use when running the test
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,
	})

	// Cleanup resources after the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform code 
	terraform.InitAndApply(t, terraformOptions)

	// Get the actual output values from the Terraform state
	actualDaId := terraform.Output(t, terraformOptions, "da_id")
	actualStId := terraform.Output(t, terraformOptions, "st_id")


	// Assert that the actual values match the expected values
	assert.Equal(t, expectedDaId, actualDaId)
	assert.Equal(t, expectedStId, actualStId)

}
