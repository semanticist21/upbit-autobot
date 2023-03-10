package main

import (
	"fmt"
	"sync"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/coininfos"
	"github.com/semanticist21/upbit-client-server/detector"
	"github.com/semanticist21/upbit-client-server/indicator"
	"github.com/semanticist21/upbit-client-server/logger"
	"github.com/semanticist21/upbit-client-server/model"
)

func main() {
	startProcess()
}

var msgs *chan string
var coins *chan indicator.CoinBollingerInfo
var errs *chan error

var wg sync.WaitGroup

func startProcess() {
	upbit := upbit.NewUpbit("", "")

	model.GetInstance()

	msgsCh := make(chan string)
	coinsCh := make(chan indicator.CoinBollingerInfo)
	errsCh := make(chan error)

	msgs = &msgsCh
	coins = &coinsCh
	errs = &errsCh
	logger.InitInstance(msgs, errs)

	go detector.InitDetector(upbit, coins)

	for {
		select {
		case coin := <-*coins:
			go coininfos.ProceedOrder(upbit, coin)
		case err := <-*errs:
			fmt.Println(err)
		case msg := <-*msgs:
			fmt.Println(msg)
		}
	}
}
