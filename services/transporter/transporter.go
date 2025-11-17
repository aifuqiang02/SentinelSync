package transporter

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"time"

	_ "github.com/lib/pq"
	"github.com/streadway/amqp"
)

// TransferNeededEvent represents an event indicating data needs to be transferred
// This should ideally be a common type shared across services
type TransferNeededEvent struct {
	FilePath string `json:"file_path"`
	FileHash string `json:"file_hash"`
	AgentID  string `json:"agent_id"`
	Timestamp time.Time `json:"timestamp"`
}

func failOnError(err error, msg string) {
	if err != nil {
		log.Fatalf("%s: %s", msg, err)
	}
}

// StartTransporter starts the transporter service, connecting to RabbitMQ and consuming transfer.needed events.
// It also interacts with PostgreSQL to update backup status.
func StartTransporter(amqpURI, queueName, dbConnStr string) {
	fmt.Println("Backup Transporter Service Starting...")

	// Connect to RabbitMQ
	connMQ, err := amqp.Dial(amqpURI)
	failOnError(err, "Failed to connect to RabbitMQ from Transporter")
	defer connMQ.Close()

	ch, err := connMQ.Channel()
	failOnError(err, "Failed to open a channel for Transporter")
	defer ch.Close()

	q, err := ch.QueueDeclare(
		queueName, // name
		true,      // durable
		false,     // delete when unused
		false,     // exclusive
		false,     // no-wait
		nil,       // arguments
	)
	failOnError(err, "Failed to declare a queue for Transporter")

	msgs, err := ch.Consume(
		q.Name, // queue
		"",     // consumer
		true,   // auto-ack
		false,  // exclusive
		false,  // no-local
		false,  // no-wait
		nil,    // args
	)
	failOnError(err, "Failed to register a consumer for Transporter")

	// Connect to PostgreSQL
	db, err := sql.Open("postgres", dbConnStr)
	failOnError(err, "Failed to connect to PostgreSQL from Transporter")
	defer db.Close()

	err = db.Ping()
	failOnError(err, "Failed to ping PostgreSQL from Transporter")
	log.Println("Transporter successfully connected to PostgreSQL!")

	forever := make(chan bool)

	go func() {
		for d := range msgs {
			var event TransferNeededEvent
			err := json.Unmarshal(d.Body, &event)
			if err != nil {
				log.Printf("Transporter: Failed to unmarshal TransferNeededEvent: %v", err)
				continue
			}

			log.Printf("Transporter received transfer.needed for file: %s (Hash: %s) from Agent: %s",
				event.FilePath, event.FileHash, event.AgentID)

			// Simulate data transfer
			fmt.Printf("Simulating transfer of data for file %s... duration 2 seconds\n", event.FilePath)
			time.Sleep(2 * time.Second) // Simulate network delay / transfer time

			// Update backup status in PostgreSQL
			_, err = db.Exec(
				"INSERT INTO file_metadata(file_path, file_hash, backup_status) VALUES($1, $2, $3) ON CONFLICT (file_path) DO UPDATE SET file_hash = $2, backup_status = $3, updated_at = CURRENT_TIMESTAMP;",
				event.FilePath, event.FileHash, "completed")
			if err != nil {
				log.Printf("Transporter: Failed to update backup status in PostgreSQL for file %s: %v", event.FilePath, err)
			} else {
				log.Printf("Transporter: Updated backup status to 'completed' for file: %s in PostgreSQL", event.FilePath)
			}
		}
	}()

	log.Printf(" [*] Transporter waiting for messages in queue '%s'. To exit press CTRL+C", q.Name)
	<-forever
}
