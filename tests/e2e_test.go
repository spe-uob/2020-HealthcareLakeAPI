package test

import (
	"fmt"
	"log"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/sethvargo/go-password/password"
)

func TestEndToEnd(t *testing.T) {
	t.Parallel()

	username := "testing"
	password, err := password.Generate(16, 6, 0, false, false)
	if err != nil {
		log.Fatal(err)
	}
	log.Printf(password)

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
	apiKey := terraform.Output(t, terraformOptions, "api_key")

	// TODO: send post request
	fmt.Println("Api Url: ", apiUrl)
	fmt.Println("Api Key: ", apiKey)
}
