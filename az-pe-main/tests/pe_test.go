package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {
	terraformDir := "../examples"

	// Define the expected values for the outputs
    expectedPeId := "/subscriptions/b665dde9-99ce-4dfe-980a-60aa599d2129/resourceGroups/azgw-poc-rg-40b01000-dev-01/providers/Microsoft.Network/privateEndpoints/azgw-poc-pe-40b01000-dev-01"

	// Define the Terraform options to use when running the test
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,
	})

	// Cleanup resources after the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform code 
	terraform.InitAndApply(t, terraformOptions)

	// Get the actual output values from the Terraform state
	actualPeId := terraform.Output(t, terraformOptions, "pe_id")

	// Assert that the actual values match the expected values
	assert.Equal(t, expectedPeId, actualPeId)
}

