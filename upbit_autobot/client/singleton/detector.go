package singleton

import (
	"fmt"
	"time"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/bollinger"
	"github.com/semanticist21/upbit-client-server/order"
)

type Detector struct {
	orders []*order.OrderInfo
}

var detector *Detector

func InitDetector() {
	logger.Msgs <- "Detector started."
	detector = &Detector{orders: fetchOrders()}

	startCycle(client)
}

func fetchOrders() []*order.OrderInfo {
	//todo
	return []*order.OrderInfo{}
}

func startCycle(client *upbit.Upbit) {
	for {
		for _, orderInfo := range detector.orders {
			candles, err := order.GetCandles(client, orderInfo.CoinId, setting.Length, setting.Minute)
			if err != nil {
				logger.Errs <- err
				continue
			}

			price, err := order.GetCurrentPrice(client, orderInfo.CoinId)
			if err != nil {
				logger.Errs <- err
				continue
			}

			_, _, lower := bollinger.GetBollinger(setting.Multiplier, &candles)

			if price < lower {
				order, err := order.BuyOrder(client, orderInfo)

				if err != nil {
					logger.Errs <- err
					continue
				}

				logger.Msgs <- "구매 완료 !!"
				logger.Msgs <- fmt.Sprintf("구매 코인 %s", order.Market)
				logger.Msgs <- fmt.Sprintf("구매 시각 %s", order.CreatedAt)
				logger.Msgs <- fmt.Sprintf("평균 구매 가격 %s", order.AvgPrice)
				logger.Msgs <- fmt.Sprintf("구매 볼륨 %s", order.Volume)
				orderInfo.BuyCount -= 1
			}

			time.Sleep(time.Millisecond * 500)
		}

		time.Sleep(time.Minute * time.Duration(setting.Minute))
	}
}
