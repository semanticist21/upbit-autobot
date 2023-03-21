package model

import (
	"bytes"

	"go.uber.org/zap"
)

type Logger struct {
	Msgs         chan string
	Errs         chan error
	Warnings     chan error
	MsgQueue     *bytes.Buffer
	IsRunning    bool
	LoggerWriter *zap.Logger
}

//go:inline
func (logger *Logger) RunLogger() {
	if logger.IsRunning {
		return
	}
	logger.IsRunning = true

	go func() {
		for {
			select {
			case msg := <-logger.Msgs:
				logger.writeLog(msg)
			case err := <-logger.Errs:
				logger.writeErr(err)
			}
		}
	}()
}

func (logger *Logger) writeLog(msg string) {
	logger.LoggerWriter.Info(msg)
}

func (logger *Logger) writeErr(err error) {
	logger.LoggerWriter.Error(err.Error())
}
