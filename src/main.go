package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

type event struct {
	ResourceType string `json:"resourceType"`
}

func handler(ctx context.Context, e event) (string, error) {
	return fmt.Sprintf("Hello world! %s", e.ResourceType), nil
}

func main() {
	lambda.Start(handler)
}
