package backup_logic

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"time"

	"SentinelSync/agent/fsmonitor"

	"github.com/streadway/amqp"
)

// FileMetadataEvent represents the event structure for metadata changes
type FileMetadataEvent struct {
	FilePath  string    `json:"file_path"`
	FileHash  string    `json:"file_hash"`
	AgentID   string    `json:"agent_id"`
	EventType string    `json:"event_type"` // create, write, remove, rename, chmod
	Timestamp time.Time `json:"timestamp"`
	IsDir     bool      `json:"is_dir"`
}

// ReadFileContent reads the content of a file in chunks.
// It returns a channel of byte slices and a channel for errors.
func ReadFileContent(filePath string, chunkSize int) (<-chan []byte, <-chan error) {
	dataChan := make(chan []byte)
	errChan := make(chan error, 1) // Buffered to prevent goroutine leak

	go func() {
		defer close(dataChan)
		defer close(errChan)

		file, err := os.Open(filePath)
		if err != nil {
			errChan <- fmt.Errorf("failed to open file %s: %w", filePath, err)
			return
		}
		defer file.Close()

		buffer := make([]byte, chunkSize)
		for {
			n, err := file.Read(buffer)
			if n > 0 {
				select {
				case dataChan <- buffer[:n]:
					// Data sent
				case <-time.After(5 * time.Second): // Timeout to prevent blocking
					errChan <- fmt.Errorf("timeout sending data for file %s", filePath)
					return
				}
			}
			if err != nil {
				if err == io.EOF {
					break // End of file
				}
				errChan <- fmt.Errorf("failed to read file %s: %w", filePath, err)
				return
			}
		}
	}()

	return dataChan, errChan
}

func failOnError(err error, msg string) {
	if err != nil {
		log.Fatalf("%s: %s", msg, err)
	}
}

// InitBackup initializes the backup logic and listens for file change events.
func InitBackup(eventChan <-chan fsmonitor.FileChangeEvent, errChan <-chan error, amqpURI, exchange, routingKey string) {
	fmt.Println("Initializing backup operation and listening for file change events...")

	conn, err := amqp.Dial(amqpURI)
	failOnError(err, "Failed to connect to RabbitMQ for backup_logic")
	// defer conn.Close() // defer here might close connection too early if not handled properly for long-running go routine

	ch, err := conn.Channel()
	failOnError(err, "Failed to open a channel for backup_logic")
	// defer ch.Close()

	err = ch.ExchangeDeclare(
		exchange, // name
		"topic",  // type
		true,     // durable
		false,    // auto-deleted
		false,    // internal
		false,    // no-wait
		nil,      // arguments
	)
	failOnError(err, "Failed to declare an exchange for backup_logic")

	go func() {
		defer conn.Close() // Ensure connection is closed when goroutine exits
		defer ch.Close()   // Ensure channel is closed when goroutine exits

		for {
			select {
			case event := <-eventChan:
				log.Printf("Received file change event: %+v", event)

				// For now, we will calculate a dummy hash.
				// In a real scenario, this would involve reading the file and computing its hash.
				// For 'remove' events, hash might not be applicable or could be marked as 'deleted'.
				fileHash := "dummy_hash_" + event.Type + "_" + time.Now().Format("20060102150405")

				metadataEvent := FileMetadataEvent{
					FilePath:  event.Path,
					FileHash:  fileHash,
					AgentID:   event.AgentID,
					EventType: event.Type,
					Timestamp: event.Timestamp,
					IsDir:     event.IsDir,
				}

				body, _ := json.Marshal(metadataEvent)
				err = ch.Publish(
					exchange,   // exchange
					routingKey, // routing key ("metadata.change")
					false,      // mandatory
					false,      // immediate
					amqp.Publishing{
						ContentType: "application/json",
						Body:        body,
					})
				if err != nil {
					log.Printf("Failed to publish message: %v", err)
				} else {
					log.Printf(" [x] Sent %s", body)
				}

			case err := <-errChan:
				log.Printf("Error from file monitor: %v", err)
			}
		}
	}()
}
