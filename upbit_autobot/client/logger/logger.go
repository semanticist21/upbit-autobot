package logger

import (
	"sync"
)

type Logger struct {
	msgs chan string
	errs chan error
}

var once = &sync.Once{}
var singleInstance *Logger

func InitInstance(msgs *chan string, errs *chan error) {
	singleInstance = &Logger{msgs: *msgs, errs: *errs}
}

func GetInstance() *Logger {
	if singleInstance == nil {
		once.Do(func() {
			singleInstance = NewLogger()
		})
	}

	return singleInstance
}

func NewLogger() *Logger {
	return &Logger{
		msgs: make(chan string),
		errs: make(chan error),
	}
}

func (l *Logger) InsertMsg(str string) {
	l.msgs <- str
}

func (l *Logger) InsertErr(err error) {
	l.msgs <- err.Error()
}
