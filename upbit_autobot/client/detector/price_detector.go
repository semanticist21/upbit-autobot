package detector

import (
	"time"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/coin"
	"github.com/semanticist21/upbit-client-server/indicator"
	"github.com/semanticist21/upbit-client-server/model"
)

// executed in seperated thread
func InitDetector(upbit *upbit.Upbit, strategy *model.Strategy, coins chan indicator.CoinBollingerInfo, errs chan error) error {
	for {
		start := time.Now()
		cycleTime := time.Second * 60

		go hasCoinsToBuy(upbit, strategy, coins, errs)

		gap := time.Since(start)
		if gap < cycleTime {
			time.Sleep(cycleTime - gap)
		}
	}

}

func hasCoinsToBuy(upbit *upbit.Upbit, strategy *model.Strategy, ch chan indicator.CoinBollingerInfo, errs chan error) {
	for {
		list, err := coin.GetCoinNames(upbit)

		if err != nil {
			errs <- err
		}

		infos, err := coin.GetCoinInfosWithBollinger(upbit, strategy, list)

		if err != nil {
			errs <- err
		}

		// verify bollinger according to strategy.
		for _, v := range infos {
			isCoinToBuy := check(v)
			if isCoinToBuy {
				ch <- v
			}
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
