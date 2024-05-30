package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {
	terraformDir := "../examples"

	// Define the expected values for the outputs
    expectedKvId := "/subscriptions/b665dde9-99ce-4dfe-980a-60aa599d2129/resourceGroups/azgw-poc-rg-40b01000-dev-01/providers/Microsoft.KeyVault/vaults/azgwpockv40b01000dev01"
    expectedKvPeId := "/subscriptions/441564b2-a7bc-432b-9f10-d30d428a4dff/resourceGroups/azgw-mat-rg-compe-prd-01/providers/Microsoft.Network/privateEndpoints/azgw-poc-pe-40b01000-dev-01"

	// Define the Terraform options to use when running the test
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,
	})

	// Cleanup resources after the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform code 
	terraform.InitAndApply(t, terraformOptions)

	// Get the actual output values from the Terraform state
	actualKvId := terraform.Output(t, terraformOptions, "kv_id")
	actualKvPeId := terraform.Output(t, terraformOptions, "kv_pe_id")

	// Assert that the actual values match the expected values
	assert.Equal(t, expectedKvId, actualKvId)
	assert.Equal(t, expectedKvPeId, actualKvPeId)
}
