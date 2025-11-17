package fsmonitor

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/fsnotify/fsnotify"
)

// FileChangeEvent represents a file system change event
type FileChangeEvent struct {
	Path      string    `json:"path"`       // 发生变更的文件路径
	Type      string    `json:"type"`       // 变更类型：create, write, remove, rename, chmod
	Timestamp time.Time `json:"timestamp"`  // 变更发生时间
	IsDir     bool      `json:"is_dir"`     // 是否是目录
	AgentID   string    `json:"agent_id"`   // 哪个Agent上发生的变更
}

// InitFileMonitor initializes the file system monitor for a given path
// It returns a channel for file change events and an error channel.
func InitFileMonitor(path string, agentID string) (<-chan FileChangeEvent, <-chan error) {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err) // Consider returning error instead of log.Fatal
	}

	eventChan := make(chan FileChangeEvent)
	errChan := make(chan error, 1) // Buffered to prevent goroutine leak

	go func() {
		defer watcher.Close()
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				eventType := ""
				if event.Op&fsnotify.Write == fsnotify.Write {
					eventType = "write"
				} else if event.Op&fsnotify.Create == fsnotify.Create {
					eventType = "create"
				} else if event.Op&fsnotify.Remove == fsnotify.Remove {
					eventType = "remove"
				} else if event.Op&fsnotify.Rename == fsnotify.Rename {
					eventType = "rename"
				} else if event.Op&fsnotify.Chmod == fsnotify.Chmod {
					eventType = "chmod"
				}

				if eventType != "" {
					fmt.Printf("Event: %s, Operation: %s\n", event.Name, eventType)
					// Determine if it's a directory (simple check for now, can be improved)
					fileInfo, err := os.Stat(event.Name)
					isDir := false
					if err == nil {
						isDir = fileInfo.IsDir()
					}

					eventChan <- FileChangeEvent{
						Path:      event.Name,
						Type:      eventType,
						Timestamp: time.Now(),
						IsDir:     isDir,
						AgentID:   agentID,
					}
				}
			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				errChan <- fmt.Errorf("fsnotify error: %w", err)
			}
		}
	}()

	err = watcher.Add(path)
	if err != nil {
		errChan <- fmt.Errorf("failed to add path %s to watcher: %w", path, err)
	}

	fmt.Printf("Monitoring file system changes in: %s\n", path)
	return eventChan, errChan
}
