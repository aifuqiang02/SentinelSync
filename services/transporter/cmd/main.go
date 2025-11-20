package main

import (
	"fmt"
	"os"

	"SentinelSync/services/transporter"
)

func main() {
	fmt.Println("Starting Transporter Service main...")

	amqpURI := os.Getenv("RABBITMQ_URI")
	if amqpURI == "" {
		amqpURI = "amqp://guest:guest@localhost:5672/"
	}

	dbConnStr := os.Getenv("DATABASE_URL")
	if dbConnStr == "" {
		dbConnStr = "postgresql://user:password@localhost:5433/sentinelsync?sslmode=disable"
	}

	queueName := "transfer.needed"

	transporter.StartTransporter(amqpURI, queueName, dbConnStr)
}
