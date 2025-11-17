package main

import (
	"fmt"
	"os"

	"SentinelSync/services/hasher"
)

func main() {
	fmt.Println("Starting Hasher Service main...")

	amqpURI := os.Getenv("RABBITMQ_URI")
	if amqpURI == "" {
		amqpURI = "amqp://guest:guest@localhost:5672/"
	}

	dbConnStr := os.Getenv("DATABASE_URL")
	if dbConnStr == "" {
		dbConnStr = "postgresql://user:password@localhost:5432/sentinelsync?sslmode=disable"
	}

	inExchange := "sentinelsync_events"
	inRoutingKey := "metadata.change"
	outExchange := "sentinelsync_events"
	outRoutingKey := "transfer.needed"

	hasher.StartHasher(amqpURI, inExchange, inRoutingKey, outExchange, outRoutingKey, dbConnStr)
}
