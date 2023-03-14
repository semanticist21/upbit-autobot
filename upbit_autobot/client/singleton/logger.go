package singleton

import "fmt"

type Logger struct {
	Msgs      chan string
	Errs      chan error
	Warnings  chan error
	IsRunning bool
}

var logger *Logger

//go:inline
func InstanceLogger() *Logger {
	return logger
}

//go:inline
func InitLogger() {
	logger = &Logger{
		Msgs:      make(chan string),
		Errs:      make(chan error),
		Warnings:  make(chan error),
		IsRunning: false,
	}
}

//go:inline
func (logger *Logger) RunLogger() {
	if logger.IsRunning {
		return
	}
	logger.IsRunning = true

	go func() {
		select {
		case msg := <-logger.Msgs:
			fmt.Println(msg)
		case err := <-logger.Errs:
			fmt.Println(err)
		}
	}()
}
