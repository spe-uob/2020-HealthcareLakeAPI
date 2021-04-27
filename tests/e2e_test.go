package test

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cognitoidentityprovider"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/sethvargo/go-password/password"
	"github.com/stretchr/testify/assert"
)

func TestEndToEnd(t *testing.T) {
	t.Parallel()

	username := "e2e-test"
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
	clientId := terraform.Output(t, terraformOptions, "client_id")

	tableName := terraform.Output(t, terraformOptions, "dynamodb_name")

	// apiKey := terraform.Output(t, terraformOptions, "api_key")

	testUnauthenticated(t, apiUrl)

	testAuthenticated(t, apiUrl, clientId, username, password)

	testDatabase(t, tableName)
}

func testUnauthenticated(t *testing.T, apiUrl string) {
	body, _ := json.Marshal(map[string]string{"resourceType": "Patient"})
	resp, err := http.Post(apiUrl+"/Patient", "application/json", bytes.NewBuffer(body))
	if err != nil {
		log.Fatalln(err)
	}
	defer resp.Body.Close()
	assert.Equal(t, 401, resp.StatusCode, "Expected StatusCode = 401 (Unauthorized)")
}

func testAuthenticated(t *testing.T, apiUrl string, clientId string, username string, password string) {
	ses, _ := session.NewSession(&aws.Config{Region: aws.String("eu-west-2")})

	// Get token
	svc := cognitoidentityprovider.New(ses)
	authRes, err := svc.InitiateAuth(&cognitoidentityprovider.InitiateAuthInput{
		AuthFlow: aws.String("USER_PASSWORD_AUTH"),
		AuthParameters: map[string]*string{
			"USERNAME": aws.String(username),
			"PASSWORD": aws.String(password),
		},
		ClientId: aws.String(clientId),
	})
	if err != nil {
		log.Fatalln(err)
	}
	token := authRes.AuthenticationResult.IdToken

	// Make request
	client := new(http.Client)
	body, _ := json.Marshal(map[string]string{"resourceType": "Patient"})
	req, _ := http.NewRequest("POST", apiUrl+"/Patient", bytes.NewBuffer(body))
	req.Header.Add("Authorization", aws.StringValue(token))
	resp, err := client.Do(req)
	if err != nil {
		log.Fatalln(err)
	}
	defer resp.Body.Close()
	assert.Equal(t, 200, resp.StatusCode, "Expected StatusCode = 200 (Authorized)")
}

func testDatabase(t *testing.T, tableName string) {
	ses, _ := session.NewSession(&aws.Config{Region: aws.String("eu-west-2")})
	svc := dynamodb.New(ses)

	input := &dynamodb.ScanInput{
		ExpressionAttributeValues: map[string]*dynamodb.AttributeValue{
			":t": {
				S: aws.String("Patient"),
			},
		},
		FilterExpression: aws.String("resourceType = :t"),
		TableName:        aws.String(tableName),
	}

	result, err := svc.Scan(input)
	if err != nil {
		log.Fatalln(err)
	}

	assert.Equal(t, int64(1), aws.Int64Value(result.Count))
}
