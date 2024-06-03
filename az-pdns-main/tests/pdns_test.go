package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {
	terraformDir := "../examples"

	// Define the expected values for the outputs
    expectedPdnsId := "/subscriptions/b665dde9-99ce-4dfe-980a-60aa599d2129/resourceGroups/azgw-poc-rg-40b01000-dev-01/providers/Microsoft.Network/privateDnsZones/azgwpocpdns40b01000dev01.privatelink.germanywestcentral.azmk8s.io"

	// Define the Terraform options to use when running the test
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,
	})

	// Cleanup resources after the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform code 
	terraform.InitAndApply(t, terraformOptions)

	// Get the actual output values from the Terraform state
	actualPdnsId := terraform.Output(t, terraformOptions, "pdns_id")

	// Assert that the actual values match the expected values
	assert.Equal(t, expectedPdnsId, actualPdnsId)
}
