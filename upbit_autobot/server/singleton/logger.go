package singleton

import (
	"bytes"
	"fmt"
	"os"

	"github.com/semanticist21/upbit-client-server/model"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var logger *model.Logger

func InstanceLogger() *model.Logger {
	return logger
}

func InitLogger() {
	logger = &model.Logger{
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

	loggerWriter := zap.New(core)

	logger.LoggerWriter = loggerWriter
}
