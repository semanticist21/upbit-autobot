package singleton

import (
	"bytes"
	"fmt"
	"os"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

type Logger struct {
	Msgs      chan string
	Errs      chan error
	Warnings  chan error
	MsgQueue  *bytes.Buffer
	IsRunning bool
}

var logger *Logger
var loggerWriter *zap.Logger

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
		MsgQueue:  new(bytes.Buffer),
		IsRunning: false,
	}

	// init loggerWriter
	f, err := os.OpenFile("history.log", os.O_RDWR|os.O_APPEND|os.O_CREATE, 0644)
	if err != nil {
		fmt.Println("로그 작성기 생성 실패")
	}

	pe := zap.NewProductionEncoderConfig()
	pe.EncodeTime = zapcore.ISO8601TimeEncoder

	fileEncoder := zapcore.NewConsoleEncoder(pe)
	consoleEncoder := zapcore.NewConsoleEncoder(pe)
	outputEncoder := zapcore.NewConsoleEncoder(pe)
	level := zap.InfoLevel

	core := zapcore.NewTee(
		zapcore.NewCore(fileEncoder, zapcore.AddSync(f), level),
		zapcore.NewCore(consoleEncoder, zapcore.AddSync(os.Stdout), level),
		zapcore.NewCore(outputEncoder, zapcore.AddSync(logger.MsgQueue), level),
	)

	loggerWriter = zap.New(core)
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
				writeLog(msg)
			case err := <-logger.Errs:
				writeErr(err)
			}
		}
	}()
}

func writeLog(msg string) {
	loggerWriter.Info(msg)
}

func writeErr(err error) {
	loggerWriter.Error(err.Error())
}
