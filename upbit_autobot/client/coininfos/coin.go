package coininfos

import (
	"strings"
	"time"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/indicator"
	"github.com/semanticist21/upbit-client-server/logger"
	"github.com/semanticist21/upbit-client-server/model"
)

func GetCoinNames(upbit *upbit.Upbit) ([]string, error) {
	markets, _, err := upbit.GetMarkets()

	if err != nil {
		return nil, err
	}

	result := []string{}

	for _, market := range markets {
		marketName := market.Market

		if strings.Contains(marketName, "KRW") {
			result = append(result, marketName)
		}
	}

	return result, nil
}

func GetCoinInfosWithBollinger(upbit *upbit.Upbit, list []string) []indicator.CoinBollingerInfo {
	bollingers := []indicator.CoinBollingerInfo{}
	strategy := model.GetInstance()

	for i, val := range list {
		if i%10 == 0 {
			time.Sleep(time.Second * 1)
		}

		bollinger, err := indicator.NewBollinger(val, strategy, upbit)
		if err != nil {
			logger.GetInstance().InsertErr(err)
			continue
		}

		bollingers = append(bollingers, *bollinger)
	}

	return bollingers
}
