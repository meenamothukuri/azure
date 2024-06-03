package test

import (
	"testing"
	"os"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)


func Test(t *testing.T) {
  terraformDir := "../examples"

  subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
 
	// Define the expected values for the outputs
  expectedRgId := "/subscriptions/" + subscriptionID + "/resourceGroups/azwe-mat-rg-tftest-dev-01"

	// Define the Terraform options to use when running the test
  terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
	TerraformDir: terraformDir,
  })

	// Cleanup resources after the test is complete
  defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform code 
  terraform.InitAndApply(t, terraformOptions)

	// Get the actual output values from the Terraform state
  actualRgId := terraform.Output(t, terraformOptions, "rg_id")

	// Assert that the actual values match the expected values
  assert.Equal(t, expectedRgId, actualRgId)
}
