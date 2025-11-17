package hasher

import (
	"crypto/sha256"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"time"

	_ "github.com/lib/pq"
	"github.com/streadway/amqp"
)

// FileMetadataEvent represents the event structure for metadata changes from agent
type FileMetadataEvent struct {
	FilePath  string    `json:"file_path"`
	FileHash  string    `json:"file_hash"` // This field will initially be empty from agent
	AgentID   string    `json:"agent_id"`
	EventType string    `json:"event_type"` // create, write, remove, rename, chmod
	Timestamp time.Time `json:"timestamp"`
	IsDir     bool      `json:"is_dir"`
}

// TransferNeededEvent represents an event indicating data needs to be transferred
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

// InitHasher starts the hasher service, connecting to RabbitMQ and consuming metadata.change events.
// It also interacts with PostgreSQL to update file metadata status.
func StartHasher(amqpURI, inExchange, inRoutingKey, outExchange, outRoutingKey, dbConnStr string) {
	fmt.Println("Backup Hasher Service Starting...")

	// Connect to RabbitMQ
	connMQ, err := amqp.Dial(amqpURI)
	failOnError(err, "Failed to connect to RabbitMQ for Hasher")
	defer connMQ.Close()

	ch, err := connMQ.Channel()
	failOnError(err, "Failed to open a channel for Hasher")
	defer ch.Close()

	// Declare input exchange and queue (metadata.change)
	err = ch.ExchangeDeclare(
		inExchange, // name
		"topic",    // type
		true,       // durable
		false,      // auto-deleted
		false,      // internal
		false,      // no-wait
		nil,        // arguments
	)
	failOnError(err, "Failed to declare input exchange for Hasher")

	qIn, err := ch.QueueDeclare(
		"metadata.change.queue", // name (should be descriptive and persistent)
		true,                    // durable
		false,                   // delete when unused
		false,                   // exclusive
		false,                   // no-wait
		nil,                     // arguments
	)
	failOnError(err, "Failed to declare input queue for Hasher")

	err = ch.QueueBind(
		qIn.Name,       // queue name
		inRoutingKey,   // routing key
		inExchange,     // exchange
		false,          // no-wait
		nil,            // arguments
	)
	failOnError(err, "Failed to bind input queue for Hasher")

	// Declare output exchange (transfer.needed)
	err = ch.ExchangeDeclare(
		outExchange, // name
		"topic",     // type
		true,        // durable
		false,       // auto-deleted
		false,       // internal
		false,       // no-wait
		nil,         // arguments
	)
	failOnError(err, "Failed to declare output exchange for Hasher")

	msgs, err := ch.Consume(
		qIn.Name, // queue
		"",       // consumer
		true,     // auto-ack
		false,    // exclusive
		false,    // no-local
		false,    // no-wait
		nil,      // args
	)
	failOnError(err, "Failed to register a consumer for Hasher")

	// Connect to PostgreSQL
	db, err := sql.Open("postgres", dbConnStr)
	failOnError(err, "Failed to connect to PostgreSQL from Hasher")
	defer db.Close()

	err = db.Ping()
	failOnError(err, "Failed to ping PostgreSQL from Hasher")
	log.Println("Hasher successfully connected to PostgreSQL!")

	forever := make(chan bool)

	go func() {
		for d := range msgs {
			var metadataEvent FileMetadataEvent
			err := json.Unmarshal(d.Body, &metadataEvent)
			if err != nil {
				log.Printf("Hasher: Failed to unmarshal FileMetadataEvent: %v", err)
				continue
			}

			log.Printf("Hasher received metadata.change for file: %s (Type: %s) from Agent: %s",
				metadataEvent.FilePath, metadataEvent.EventType, metadataEvent.AgentID)

			// Update backup status to 'hashing_in_progress' in PostgreSQL
			_, err = db.Exec(
				"INSERT INTO file_metadata(file_path, file_hash, backup_status) VALUES($1, $2, $3) ON CONFLICT (file_path) DO UPDATE SET file_hash = $2, backup_status = $3, updated_at = CURRENT_TIMESTAMP;",
				metadataEvent.FilePath, "pending_hash", "hashing_in_progress")
			if err != nil {
				log.Printf("Hasher: Failed to update backup status to 'hashing_in_progress' for file %s: %v", metadataEvent.FilePath, err)
			} else {
				log.Printf("Hasher: Updated backup status to 'hashing_in_progress' for file: %s in PostgreSQL", metadataEvent.FilePath)
			}

			// Simulate file content for hashing (In a real scenario, this would access the file)
			fileContent := []byte(fmt.Sprintf("%s-%s-%s", metadataEvent.FilePath, metadataEvent.EventType, metadataEvent.Timestamp.String()))
			hash := sha256.Sum256(fileContent)
			fileHash := fmt.Sprintf("%x", hash)

			log.Printf("Hasher calculated hash for file %s: %s", metadataEvent.FilePath, fileHash)

			// Prepare TransferNeededEvent
			transferEvent := TransferNeededEvent{
				FilePath:  metadataEvent.FilePath,
				FileHash:  fileHash,
				AgentID:   metadataEvent.AgentID,
				Timestamp: time.Now(),
			}

			body, _ := json.Marshal(transferEvent)
			err = ch.Publish(
				outExchange,   // exchange
				outRoutingKey, // routing key ("transfer.needed")
				false,         // mandatory
				false,         // immediate
				amqp.Publishing{
					ContentType: "application/json",
					Body:        body,
				})
			if err != nil {
				log.Printf("Hasher: Failed to publish transfer.needed message: %v", err)
			} else {
				log.Printf("Hasher: [x] Sent transfer.needed %s", body)

				// Update backup status to 'hashing_completed' in PostgreSQL after publishing
				_, err = db.Exec(
					"INSERT INTO file_metadata(file_path, file_hash, backup_status) VALUES($1, $2, $3) ON CONFLICT (file_path) DO UPDATE SET file_hash = $2, backup_status = $3, updated_at = CURRENT_TIMESTAMP;",
					metadataEvent.FilePath, fileHash, "hashing_completed")
				if err != nil {
					log.Printf("Hasher: Failed to update backup status to 'hashing_completed' for file %s: %v", metadataEvent.FilePath, err)
				} else {
					log.Printf("Hasher: Updated backup status to 'hashing_completed' for file: %s in PostgreSQL", metadataEvent.FilePath)
				}
			}
		}
	}()

	log.Printf(" [*] Hasher waiting for messages in queue '%s'. To exit press CTRL+C", qIn.Name)
	<-forever
}
