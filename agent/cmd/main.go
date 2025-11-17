package main

import (
	"fmt"
	"os"
	"time"

	"SentinelSync/agent/backup_logic"
	"SentinelSync/agent/fsmonitor"
)

func main() {
	fmt.Println("SentinelSync Agent Starting...")

	var monitorPath string
	monitorPath = "./test_data" // For testing, adjust as needed

	agentID := "agent-001"

	// Create a directory for testing if it doesn't exist
	if _, err := os.Stat(monitorPath); os.IsNotExist(err) {
		os.Mkdir(monitorPath, 0755)
		fmt.Printf("Created test directory: %s\n", monitorPath)
	}

	// RabbitMQ Connection Details
	amqpURI := "amqp://guest:guest@localhost:5672/" // Replace with your RabbitMQ URI
	exchangeName := "sentinelsync_events"
	metadataRoutingKey := "metadata.change"

	// Initialize file system monitor
	eventChan, errChan := fsmonitor.InitFileMonitor(monitorPath, agentID)

	// Initialize backup logic with the event channels and RabbitMQ details
	backup_logic.InitBackup(eventChan, errChan, amqpURI, exchangeName, metadataRoutingKey)

	fmt.Println("Agent started. Monitoring file system for changes and sending events to RabbitMQ...")

	// Keep the main goroutine running indefinitely, or use a context for graceful shutdown
	select {
	case <-time.After(60 * time.Minute): // Example: Keep alive for an hour for testing
		fmt.Println("Agent running for an hour, exiting.")
	}
}
