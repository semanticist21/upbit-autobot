package order

import (
	"fmt"
	"strconv"

	"github.com/sangx2/upbit"
	"github.com/sangx2/upbit/model/exchange"
	"github.com/sangx2/upbit/model/exchange/order"
	"github.com/semanticist21/upbit-client-server/converter"
	"github.com/semanticist21/upbit-client-server/model"
)

type Minutes int

const (
	Three    Minutes = 3
	Five     Minutes = 5
	Fiften   Minutes = 15
	Thirty   Minutes = 30
	Sixty    Minutes = 60
	TwoForty Minutes = 240
)

func IntToMinutesType(val int) (Minutes, error) {
	switch val {
	case 3, 5, 15, 30, 60, 240:
		return Minutes(val), nil
	default:
		return 0, fmt.Errorf("%d분 :: 적합한 분봉이 아닙니다. 3, 5, 15, 30, 60, 240분 중 하나여야 합니다", val)
	}
}

func GetCandles(client *upbit.Upbit, marketName string, length int, minute Minutes) ([]float64, error) {
	candles, _, err := client.GetMinuteCandles(marketName, "", strconv.Itoa(length), strconv.Itoa(int(minute)))

	if err != nil {
		return nil, err
	}

	prices := []float64{}
	for _, v := range candles {
		prices = append(prices, v.TradePrice)
	}

	return prices, nil
}

func GetAllCoinMarketNames(client *upbit.Upbit) (map[string]string, error) {
	market, _, err := client.GetMarkets()
	coinInfos := make(map[string]string)

	if err != nil {
		return nil, err
	}

	for _, info := range market {
		coinInfos[info.KoreanName] = info.Market
	}

	return coinInfos, nil
}

func BuyOrder(client *upbit.Upbit, orderInfo *model.OrderInfo) (*order.Order, error) {
	order, _, err := client.PurchaseOrder(orderInfo.MarketName, "", converter.Float64ToString(orderInfo.BuyAmountInKrw, 2), exchange.ORDER_TYPE_PRICE, "")

	if err != nil {
		return nil, err
	}

	return order, nil
}

func GetCurrentPrice(client *upbit.Upbit, coinId string) (float64, error) {
	tickers, _, err := client.GetTickers([]string{coinId})

	if err != nil {
		return -1, err
	}

	for _, ticker := range tickers {
		return ticker.TradePrice, nil
	}

	return -1, fmt.Errorf("취득된 가격정보가 없습니다")
}
