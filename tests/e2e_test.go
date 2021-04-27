package test

import (
	"log"
	"net/http"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/sethvargo/go-password/password"
	"github.com/stretchr/testify/assert"
)

func TestEndToEnd(t *testing.T) {
	t.Parallel()

	username := "testing"
	password, err := password.Generate(16, 6, 0, false, false)
	if err != nil {
		log.Fatal(err)
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"username": username,
			"password": password,
			"stage":    "test",
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	apiUrl := terraform.Output(t, terraformOptions, "api_url")
	// apiKey := terraform.Output(t, terraformOptions, "api_key")

	testUnauthenticated(t, apiUrl)
}

func testUnauthenticated(t *testing.T, apiUrl string) {
	resp, err := http.Get(apiUrl)
	if err != nil {
		log.Fatalln(err)
	}
	defer resp.Body.Close()
	assert.Equal(t, resp.StatusCode, 401, "Expected StatusCode = 401 (Unauthorized)")
}
