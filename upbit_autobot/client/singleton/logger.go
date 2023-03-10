package singleton

import "fmt"

type Logger struct {
	Msgs     chan string
	Errs     chan error
	Warnings chan error
}

var logger *Logger
var IsRunning = false

//go:inline
func InstanceLogger() *Logger {
	return logger
}

//go:inline
func InitLogger() {
	logger = &Logger{
		Msgs:     make(chan string),
		Errs:     make(chan error),
		Warnings: make(chan error),
	}
}

//go:inline
func RunLogger() {
	if IsRunning {
		return
	}

	IsRunning = true
	go func() {
		select {
		case msg := <-logger.Msgs:
			fmt.Println(msg)
		case err := <-logger.Errs:
			fmt.Println(err)
		}
	}()
}
