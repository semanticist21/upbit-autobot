package singleton

import "fmt"

type Logger struct {
	Msgs chan string
	Errs chan error
}

var logger *Logger
var IsRunning = false

func InstanceLogger() *Logger {
	return logger
}

func InitLogger() {
	logger = &Logger{
		Msgs: make(chan string),
		Errs: make(chan error),
	}
}

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
