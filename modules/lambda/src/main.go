package main

import (
	"encoding/json"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

// dynamodb session
type db struct {
	svc *dynamodb.DynamoDB
}

func client() *db {
	// create dynamodb client
	return &db{
		svc: dynamodb.New(session.Must(session.NewSession())),
	}
}

// extracts the JSON and writes it to DynamoDB
func post(body string) (map[string]interface{}, error) {
	db := client()
	// unmarshal the request body
	var data map[string]interface{}
	if err := json.Unmarshal([]byte(body), &data); err != nil {
		log.Fatal(err)
	}
	// PutItem in table
	err := db.put(data)
	return data, err
}

func (s *db) put(data map[string]interface{}) error {
	// convert each attribute to dynamodb.AttributeValue
	var vv = make(map[string]*dynamodb.AttributeValue)
	for k, v := range data {
		x := (v.(string))
		xx := &(x)
		vv[k] = &dynamodb.AttributeValue{S: xx}
	}
	// write to dynamodb
	params := &dynamodb.PutItemInput{
		Item:      vv,
		TableName: aws.String(os.Getenv("TABLE_NAME")), // Required
	}
	_, err := s.svc.PutItem(params)
	return err
}

func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// log body
	log.Println("Received body: ", request.Body)

	// write to dynamodb
	item, err := post(request.Body)
	if err != nil {
		log.Println("Error calling post() %e", err.Error())

		return events.APIGatewayProxyResponse{
			Body:       "Error",
			StatusCode: 500,
		}, nil
	}

	// log and return result
	log.Println("Wrote item: ", item)
	return events.APIGatewayProxyResponse{
		Body:       "Success \n",
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(handler)
}
