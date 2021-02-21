#!/bin/sh

cd $1
GOOS=linux CGO_ENABLED=0 go build -o ../main main.go
