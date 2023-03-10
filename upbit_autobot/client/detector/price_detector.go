package detector

import (
	"fmt"
	"time"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/coininfos"
	"github.com/semanticist21/upbit-client-server/indicator"
	"github.com/semanticist21/upbit-client-server/logger"
)

// executed in seperated thread
func InitDetector(upbit *upbit.Upbit, coins *chan indicator.CoinBollingerInfo) {
	fmt.Println("Started to fetch coin data.")
	go hasCoinsToBuy(upbit, coins)
}

func hasCoinsToBuy(upbit *upbit.Upbit, ch *chan indicator.CoinBollingerInfo) {
	for {
		start := time.Now()
		cycleTime := time.Second * 60

		list, err := coininfos.GetCoinNames(upbit)

		if err != nil {
			logger.GetInstance().InsertErr(err)
			logger.GetInstance().InsertErr(fmt.Errorf("the task was canceled"))
			return
		}

		infos := coininfos.GetCoinInfosWithBollinger(upbit, list)

		// verify bollinger according to strategy.
		for _, v := range infos {
			isCoinToBuy := check(v)
			if !isCoinToBuy {
				*ch <- v
			}
		}

		gap := time.Since(start)
		if gap < cycleTime {
			time.Sleep(cycleTime - gap)
		}
	}
}

func check(info indicator.CoinBollingerInfo) bool {
	if info.Current < info.Lower {
		return true
	} else {
		return false
	}
}
