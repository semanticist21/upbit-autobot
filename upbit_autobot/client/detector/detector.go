package detector

import (
	"fmt"
	"math"
	"time"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/bollinger"
	"github.com/semanticist21/upbit-client-server/converter"
	"github.com/semanticist21/upbit-client-server/model"
	"github.com/semanticist21/upbit-client-server/order"
	"github.com/semanticist21/upbit-client-server/singleton"
)

type CycleStarter struct {
}

func (starter *CycleStarter) StartInit(client *upbit.Upbit) {
	StartSellItems()
	StartDetectorCycle(client)
}

//go:inline
func StartSellItems() {

}

//go:inline
func StartDetectorCycle(client *upbit.Upbit) {
	go StartBuyDetectorBot(client)
	go StartSellDetectorBot(client)
}

//go:inline
func StartBuyDetectorBot(client *upbit.Upbit) {
	singleton.InstanceLogger().Msgs <- "구매 감시 봇 작동 시작."
	for {
		if len(singleton.InstanceItems().Items) == 0 {
			continue
		}

		markets, _, _ := client.GetMarkets()
		marketMap := make(map[string]bool)

		for _, market := range markets {
			marketMap[market.Market] = true
		}
		// check whether market exists.
		for i := 0; i < len(singleton.InstanceItems().Items); i++ {
			// prevent from indexing non-existant item
			// for case when item deleted during iteration.
			if singleton.InstanceItems().Items[i] == nil {
				continue
			}

			item := singleton.InstanceItems().Items[i]
			if _, ok := marketMap[item.CoinMarketName]; !ok {
				singleton.InstanceLogger().Errs <- fmt.Errorf("%s 해당 마켓이 업비트에 존재하지 않아 구매 감시대상에서 제외합니다. 뷰에 반영을 원할 시 새로고침을 눌러주세요", item.CoinMarketName)
				singleton.InstanceItems().Items = append(singleton.InstanceItems().Items[:i], singleton.InstanceItems().Items[i+1:]...)
				singleton.SaveStrategyItems()
				i -= 1
				continue
			}

			// 회수 소진 시 패스
			if item.PurchaseCount == 0 {
				continue
			}

			if item.LastBoughtTimestamp != "" {
				parsedTime, err := converter.Iso8601StringToTime(item.LastBoughtTimestamp)
				if err != nil {
					singleton.InstanceLogger().Errs <- err
					continue
				}

				// 기준 분봉 캔들보다 마지막 구매 시기가 짧을 시 패스
				diff := time.Since(parsedTime)
				if diff.Minutes() < float64(item.CandleBaseMinute) {
					continue
				}
			}

			minutes, err := order.IntToMinutesType(item.CandleBaseMinute)
			if err != nil {
				singleton.InstanceLogger().Errs <- err
				continue
			}

			candles, err := order.GetCandles(client, item.CoinMarketName, item.BollingerLength, minutes)
			if err != nil {
				singleton.InstanceLogger().Errs <- err
				continue
			}

			if len(candles) != item.BollingerLength {
				singleton.InstanceLogger().Errs <- fmt.Errorf("%s 볼린저 밴드 분석을 위한 캔들의 개수가 부족합니다. 필요한 캔들 개수 : %d, 반환된 캔들 개수 : %d", item.CoinMarketName, item.BollingerLength, len(candles))
				continue
			}

			_, _, lower := bollinger.GetBollinger(item.BollingerMultiplier, &candles)
			price, err := order.GetCurrentPrice(client, item.CoinMarketName)

			if err != nil {
				singleton.InstanceLogger().Errs <- err
				continue
			}

			// todo
			// 테스트용으로 반대로 해둠
			if price < lower {
				continue
			}

			// all requirements are satisfied. proceed with order
			buyAmountInKrw := price * item.DesiredBuyAmount
			buyAmountInKrw = math.Round(buyAmountInKrw)

			singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s를 %.4f가격에 %.4f(한화 : %f) 만큼 매수를 시도합니다.", item.CoinMarketName, price, item.DesiredBuyAmount, buyAmountInKrw)
			orderInfo := model.OrderInfo{MarketName: item.CoinMarketName, BuyAmountInKrw: buyAmountInKrw}

			orderResult, err := order.BuyOrder(client, &orderInfo)
			if err != nil {
				singleton.InstanceLogger().Errs <- fmt.Errorf("%s #에러 발생 코인 이름: %s", err.Error(), item.CoinMarketName)
				continue
			}

			// order completion !!
			// reduce count in strategy item
			// put timestamp
			// remove if count == zero
			// put order info to selltarget items.
			// end if proflt/loss is 0%

			time.Sleep(time.Millisecond * 500)
			orderedResult, _, _ := client.GetOrder(orderResult.UUID, "")

			fmt.Println(orderResult.UUID)
			fmt.Printf("%+v\n", orderedResult)
			singleton.InstanceLogger().Msgs <- fmt.Sprintf("매수 성공! 매수 코인 : %s, 매수 볼륨(KRW) : %s,", orderResult.Market, orderResult.Price)

			item.PurchaseCount -= 1
			item.LastBoughtTimestamp = converter.NowToISO8601()

			if item.PurchaseCount == 0 {
				singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 구매회수 소진되어 전략에서 삭제됩니다.", item.CoinMarketName)
				singleton.InstanceItems().Items = append(singleton.InstanceItems().Items[:i], singleton.InstanceItems().Items[i+1:]...)
				singleton.SaveStrategyItems()
			}
		}

		time.Sleep(time.Millisecond * 300000)
	}
}

//go:inline
func StartSellDetectorBot(client *upbit.Upbit) {
	singleton.InstanceLogger().Msgs <- "판매 감시 봇 작동 시작."
	for {
		time.Sleep(time.Millisecond * 5000)
	}
}
