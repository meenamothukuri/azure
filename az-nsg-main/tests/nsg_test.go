package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {
	terraformDir := "../examples"

	// Define the expected values for the outputs
    expectedNSGId := "/subscriptions/8d0c1468-bc5a-4da8-a3ac-e40c4a49ecb4/resourceGroups/azwe-nrw-rg-40b01000-dev-01/providers/Microsoft.Network/networkSecurityGroups/azwe-nrw-nsg-40b01000-dev-01"

	// Define the Terraform options to use when running the test
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,
	})

	// Cleanup resources after the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform code 
	terraform.InitAndApply(t, terraformOptions)

	// Get the actual output values from the Terraform state
	actualNSGId := terraform.Output(t, terraformOptions, "nsg_id")

	// Assert that the actual values match the expected values
	assert.Equal(t, expectedNSGId, actualNSGId)
}
