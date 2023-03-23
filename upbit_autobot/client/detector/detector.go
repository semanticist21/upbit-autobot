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
	StartDetectorCycle(client)
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
			item := singleton.InstanceItems().Items[i]

			// prevent from indexing non-existant item
			// for case when item deleted during iteration.
			if item == nil {
				continue
			}

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
			// price requirements
			// before entering into action
			if price < lower {
				continue
			}

			// all requirements are satisfied. proceed with order
			buyAmountInKrw := price * item.DesiredBuyAmount
			buyAmountInKrw = math.Round(buyAmountInKrw)

			singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s를 %.4f가격에 %.4f(한화 : %f) 만큼 매수를 시도합니다.", item.CoinMarketName, price, item.DesiredBuyAmount, buyAmountInKrw)
			orderInfo := model.BuyOrderInfo{MarketName: item.CoinMarketName, BuyAmountInKrw: buyAmountInKrw}

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
			singleton.InstanceLogger().Msgs <- fmt.Sprintf("매수 성공! 매수 코인 : %s, 매수 볼륨(KRW) : %s", orderResult.Market, orderResult.Price)

			item.PurchaseCount -= 1
			item.LastBoughtTimestamp = converter.NowToISO8601()

			if item.PurchaseCount == 0 {
				singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 코인 구매회수 소진되었습니다.", item.CoinMarketName)
			}

			// if profit line and lossline 0, pass inserting sell detector bot
			if item.ProfitLinePercent == 0. && item.LossLinePercent == 0. {
				continue
			}

			// wait until order complete
			time.Sleep(time.Millisecond * 500)
			orderedResult, _, err := client.GetOrder(orderResult.UUID, "")

			if err != nil || orderResult.State != "done" {
				time.Sleep(time.Millisecond * 500)
				orderedResult, _, err = client.GetOrder(orderResult.UUID, "")

				if err != nil || orderResult.State != "done" {
					singleton.InstanceLogger().Errs <- fmt.Errorf("볼륨 취득에 실패했습니다. 판매 감시봇 진입 실패! #에러 발생 코인 이름: %s", item.CoinMarketName)
					continue
				}
			}

			// check whether the item exists in sell target items.
			hasExistingItem := false

			for i := 0; i < len(singleton.InstanceSellTargetItems().BoughtItems); i++ {
				existingSellTargetItem := singleton.InstanceSellTargetItems().BoughtItems[i]

				// if item has same id
				if item.ItemId == existingSellTargetItem.ItemId && item.CoinMarketName == existingSellTargetItem.CoinMarketName {
					currentExecutedVolume, _ := converter.StringToFloatWithDigit(orderedResult.ExecutedVolume, 4)
					var currentExecutedPrice float64 = 0.

					for _, trade := range orderedResult.Trades {
						if item.CoinMarketName == trade.Market {
							currentExecutedPrice, _ = converter.StringToFloatWithDigit(trade.Price, 2)
						}
					}

					if currentExecutedPrice == 0. {
						singleton.InstanceLogger().Errs <- fmt.Errorf("트레이드 정보 취득 오류로 감시봇 진입 실패했습니다. #에러 발생 코인 이름: %s", item.CoinMarketName)
						break
					}

					// get new AvgPrice
					newExecutedVolume := currentExecutedVolume + existingSellTargetItem.ExecutedVolume
					newAvgPrice := ((existingSellTargetItem.AvgBuyPrice * existingSellTargetItem.ExecutedVolume) + (currentExecutedPrice * currentExecutedVolume)) / (newExecutedVolume)
					newProfitTargetPrice := newAvgPrice + newAvgPrice*(item.ProfitLinePercent/100)
					newLossTargetPrice := newAvgPrice - newAvgPrice*(item.ProfitLinePercent/100)

					newAvgPrice = converter.FloatToFloatwithDigit(newAvgPrice, 4)
					newExecutedVolume = converter.FloatToFloatwithDigit(newExecutedVolume, 4)
					newProfitTargetPrice = converter.FloatToFloatwithDigit(newProfitTargetPrice, 4)
					newLossTargetPrice = converter.FloatToFloatwithDigit(newLossTargetPrice, 4)

					// when user don't want to sell with profit
					if item.ProfitLinePercent == 0. {
						newProfitTargetPrice = 0.
					}

					// when user don't want to sell with loss
					if item.LossLinePercent == 0. {
						newLossTargetPrice = 0.
					}

					// if there is too small gap like BTT, + 0.0001 price
					if newProfitTargetPrice == newAvgPrice {
						newProfitTargetPrice += 0.0001
					}

					if newLossTargetPrice == newAvgPrice {
						newLossTargetPrice -= 0.0001
					}

					existingSellTargetItem.AvgBuyPrice = newAvgPrice
					existingSellTargetItem.ExecutedVolume = newExecutedVolume
					existingSellTargetItem.ProfitTargetPrice = newProfitTargetPrice
					existingSellTargetItem.LossTargetPrice = newLossTargetPrice

					singleton.SaveSellTargetStrategyItems()
					hasExistingItem = true
					singleton.InstanceLogger().Msgs <- fmt.Sprintf("판매 감시 리스트 기존 아이템 수정 완료 %+v", existingSellTargetItem)
					break
				}
			}

			// if processed, then go to next coin
			if hasExistingItem {
				continue
			}

			var currentExecutedPrice float64 = 0.

			for _, trade := range orderedResult.Trades {
				if item.CoinMarketName == trade.Market {
					currentExecutedPrice, _ = converter.StringToFloatWithDigit(trade.Price, 2)
				}
			}

			if currentExecutedPrice == 0. {
				singleton.InstanceLogger().Errs <- fmt.Errorf("트레이드 정보 취득 오류로 감시봇 진입 실패했습니다. #에러 발생 코인 이름: %s", item.CoinMarketName)
				continue
			}

			currentExecutedVolume, err := converter.StringToFloatWithDigit(orderedResult.ExecutedVolume, 4)
			if err != nil {
				singleton.InstanceLogger().Errs <- fmt.Errorf("볼륨 정보 취득 오류로 감시봇 진입 실패했습니다. #에러 발생 코인 이름: %s", item.CoinMarketName)
				continue
			}

			profitTargetPrice := converter.FloatToFloatwithDigit(currentExecutedPrice+currentExecutedPrice*(item.ProfitLinePercent/100), 4)
			lossTargetPrice := converter.FloatToFloatwithDigit(currentExecutedPrice-currentExecutedPrice*(item.LossLinePercent/100), 4)
			currentExecutedPrice = converter.FloatToFloatwithDigit(currentExecutedPrice, 4)
			currentExecutedVolume = converter.FloatToFloatwithDigit(currentExecutedVolume, 4)

			// when user don't want to sell with profit
			if item.ProfitLinePercent == 0. {
				profitTargetPrice = 0.
			}

			// when user don't want to sell with loss
			if item.LossLinePercent == 0. {
				lossTargetPrice = 0.
			}

			// if there is too small gap like BTT, + 0.0001 price
			if profitTargetPrice == currentExecutedPrice {
				profitTargetPrice += 0.0001
			}

			if lossTargetPrice == currentExecutedPrice {
				lossTargetPrice -= 0.0001
			}

			// if don't have existing item, add new.
			newSellTargetItem := model.SellTargetStrategyItemInfo{ItemId: item.ItemId, CoinMarketName: item.CoinMarketName, AvgBuyPrice: currentExecutedPrice, ExecutedVolume: currentExecutedVolume, ProfitTargetPrice: profitTargetPrice, LossTargetPrice: lossTargetPrice}
			singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems, &newSellTargetItem)
			singleton.SaveSellTargetStrategyItems()
			singleton.InstanceLogger().Msgs <- fmt.Sprintf("판매 감시 리스트 진입 완료 %+v", newSellTargetItem)
		}

		// 전체 사이클 회수(최대 10개니 대략 5~6초 소요)
		// whole cycle wait(without it, maximum it takes 5-6seconds)
		time.Sleep(time.Millisecond * 1000)
	}
}

//go:inline
func StartSellDetectorBot(client *upbit.Upbit) {
	singleton.InstanceLogger().Msgs <- "판매 감시 봇 작동 시작."
	for {
		if len(singleton.InstanceSellTargetItems().BoughtItems) == 0 {
			continue
		}

		dic := make(map[string]bool)
		for _, item := range singleton.InstanceItems().Items {
			dic[item.ItemId] = true
		}

		for i := 0; i < len(singleton.InstanceSellTargetItems().BoughtItems); i++ {
			sellTargetItem := singleton.InstanceSellTargetItems().BoughtItems[i]

			// prevent from indexing non-existant item
			// for case when item deleted during iteration.
			if sellTargetItem == nil {
				continue
			}

			// in the case the item doesn't exist any more in the buy monitor list
			// remove sell target item
			if _, ok := dic[sellTargetItem.ItemId]; !ok {
				singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 해당 코인이 목록에 존재하지 않아 판매 감시 대상에서 제외합니다.", sellTargetItem.CoinMarketName)
				singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems[:i], singleton.InstanceSellTargetItems().BoughtItems[i+1:]...)
				singleton.SaveSellTargetStrategyItems()
				i -= 1
				continue
			}

			// take info whether sell target volume is smaller than the balance in the account
			accounts, _, err := client.GetAccounts()
			if err == nil {
				for _, account := range accounts {
					if account.GetMarketID() == sellTargetItem.CoinMarketName {
						accBalance, err := converter.StringToFloatWithDigit(account.Balance, 4)
						if err != nil {
							singleton.InstanceLogger().Errs <- fmt.Errorf("%s, #에러 발생 코인 이름: %s", err.Error(), sellTargetItem.CoinMarketName)
						}

						if accBalance < sellTargetItem.ExecutedVolume {
							singleton.InstanceLogger().Msgs <- fmt.Sprintf("전략 매도 잔고보다 현재 코인의 잔고가 더 낮아 현재 코인의 잔고로 재조정합니다. #코인 이름: %s, #전략 잔고: %.4f, #계좌 잔고 %.4f", sellTargetItem.CoinMarketName, sellTargetItem.ExecutedVolume, accBalance)
							sellTargetItem.ExecutedVolume = accBalance
						}
						break
					}
				}
			}

			// if volume to sell is 0 then delete and continue
			if sellTargetItem.ExecutedVolume == 0 {
				singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 해당 코인의 매도 타겟 볼륨이 0이기에 판매 감시 대상에서 제외합니다.", sellTargetItem.CoinMarketName)
				singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems[:i], singleton.InstanceSellTargetItems().BoughtItems[i+1:]...)
				singleton.SaveSellTargetStrategyItems()
				i -= 1
				continue
			}

			// start profit detect!!
			if sellTargetItem.ProfitTargetPrice != 0 {
				price, err := order.GetCurrentPrice(client, sellTargetItem.CoinMarketName)
				if err != nil {
					singleton.InstanceLogger().Errs <- err
					continue
				}

				if price > sellTargetItem.ProfitTargetPrice {

				}
			}

			// start sell detect!!
			if sellTargetItem.LossTargetPrice != 0 {
				price, err := order.GetCurrentPrice(client, sellTargetItem.CoinMarketName)
				if err != nil {
					singleton.InstanceLogger().Errs <- err
					continue
				}

				if price < sellTargetItem.LossTargetPrice {
					sellOrderInfo := model.SellOrderInfo{MarketName: sellTargetItem.CoinMarketName, Volume: sellTargetItem.ExecutedVolume}
					orderResult, err := order.SellOrder(client, &sellOrderInfo)

					if err != nil {
						singleton.InstanceLogger().Errs <- fmt.Errorf("%s #에러 발생 코인 이름: %s", err.Error(), sellTargetItem.CoinMarketName)
						continue
					}

					for j := 0; j < len(singleton.BuyTargetitems.Items); j++ {
						if singleton.BuyTargetitems.Items[j] == nil {
							continue
						}

						if singleton.BuyTargetitems.Items[j].ItemId == sellTargetItem.ItemId {
							singleton.InstanceItems()
							break
						}
					}
					// delete from sell target coin
					singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems[:i], singleton.InstanceSellTargetItems().BoughtItems[i+1:]...)
					singleton.SaveSellTargetStrategyItems()

					singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 손절 완료, 매도 양: %.4f, 매도 가격: %s", sellTargetItem.CoinMarketName, sellTargetItem.ExecutedVolume, orderResult.Price)

					continue
				}
			}

		}

		time.Sleep(time.Millisecond * 1000)
	}
}
