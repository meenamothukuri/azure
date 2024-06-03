package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {
	terraformDir := "../examples"

	// Define the expected values for the outputs
    expectedAksId := "/subscriptions/b665dde9-99ce-4dfe-980a-60aa599d2129/resourceGroups/azgw-poc-rg-40b01000-dev-01/providers/Microsoft.ContainerService/managedClusters/azgw-poc-aks-40b01000-dev-01"

	expectedAksPublicNetworkAccessEnabled := "false"
	expectedAksPrivateClusterEnabled := "true"
	expectedAksPrivateDnsZoneId := "/subscriptions/441564b2-a7bc-432b-9f10-d30d428a4dff/resourceGroups/azgw-mat-rg-j2cppdns-prd-01/providers/Microsoft.Network/privateDnsZones/azgwmatpdnsj2cppdnsprd01.privatelink.germanywestcentral.azmk8s.io"

	// Define the Terraform options to use when running the test
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,
	})

	// Cleanup resources after the test is complete
	defer terraform.Destroy(t, terraformOptions)

	// Apply the Terraform code 
	terraform.InitAndApply(t, terraformOptions)

	// Get the actual output values from the Terraform state
	actualAksId := terraform.Output(t, terraformOptions, "aks_id")
	actualAksPublicNetworkAccessEnabled := terraform.Output(t, terraformOptions, "aks_public_network_access_enabled")
	actualAksPrivateClusterEnabled := terraform.Output(t, terraformOptions, "aks_private_cluster_enabled")
	actualAksPrivateDnsZoneId := terraform.Output(t, terraformOptions, "aks_private_dns_zone_id")

	// Assert that the actual values match the expected values
	assert.Equal(t, expectedAksId, actualAksId)
	assert.Equal(t, expectedAksPublicNetworkAccessEnabled, actualAksPublicNetworkAccessEnabled)
	assert.Equal(t, expectedAksPrivateClusterEnabled, actualAksPrivateClusterEnabled)
	assert.Equal(t, expectedAksPrivateDnsZoneId, actualAksPrivateDnsZoneId)
}
