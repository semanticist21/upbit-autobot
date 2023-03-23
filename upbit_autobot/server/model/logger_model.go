package model

import (
	"bytes"

	"github.com/gorilla/websocket"
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

//go:inline
func (logger *Logger) writeLog(msg string) {
	logger.LoggerWriter.Info(msg)
}

//go:inline
func (logger *Logger) writeErr(err error) {
	logger.LoggerWriter.Error(err.Error())
}

//go:inline
func (logger *Logger) WriteLogReponse(conn *websocket.Conn) {
	if logger.MsgQueue.Len() == 0 {
		return
	}

	conn.WriteMessage(websocket.TextMessage, logger.MsgQueue.Bytes())
	logger.MsgQueue.Reset()
}
