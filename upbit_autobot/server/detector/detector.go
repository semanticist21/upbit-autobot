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

var TheBuyCycleOngoing = false
var TheSellCycleOngoing = false

type CycleStarter struct {
}

func (starter *CycleStarter) StartInit(client *upbit.Upbit) {
	StartDetectorCycle(client)
}

func StartDetectorCycle(client *upbit.Upbit) {
	go StartBuyDetectorBot(client)
	go StartSellDetectorBot(client)
	go func() {
		for {
			time.Sleep(time.Second * 30)
			sendKrwAndCoinBalance(client)
		}
	}()
}

func StartBuyDetectorBot(client *upbit.Upbit) {
	singleton.InstanceLogger().Msgs <- "구매 감시 봇 작동 시작."
	for {
		// 전체 사이클 회수(최대 10개니 대략 5~6초 소요)
		// whole cycle wait(without it, maximum it takes 5-6seconds)
		TheBuyCycleOngoing = false
		time.Sleep(time.Millisecond * 5000)
		TheBuyCycleOngoing = true

		if len(singleton.InstanceBuyTargetItems().Items) == 0 {
			continue
		}

		markets, _, err := client.GetMarkets()
		marketMap := make(map[string]bool)

		if err != nil {
			singleton.InstanceLogger().Errs <- fmt.Errorf("마켓 정보 조회 중 오류 발생 %s", err.Error())
		} else {
			for _, market := range markets {
				marketMap[market.Market] = true
			}
		}

		// check whether market exists.
		for i := 0; i < len(singleton.InstanceBuyTargetItems().Items); i++ {
			item := singleton.InstanceBuyTargetItems().Items[i]

			// prevent from indexing non-existant item
			// for case when item deleted during iteration.
			if item == nil {
				continue
			}

			if len(marketMap) != 0 {
				if _, ok := marketMap[item.CoinMarketName]; !ok {
					singleton.InstanceLogger().Errs <- fmt.Errorf("%s 해당 마켓이 업비트에 존재하지 않아 구매 감시 대상에서 제외합니다", item.CoinMarketName)
					singleton.InstanceBuyTargetItems().Items = append(singleton.InstanceBuyTargetItems().Items[:i], singleton.InstanceBuyTargetItems().Items[i+1:]...)
					singleton.SaveStrategyBuyTargetItems()

					// queue in deletion
					data := model.ItemCollectionForSocketNew()
					data.DeletedItemId = &item.ItemId
					singleton.InstanceItemsCollectionCh() <- data

					i -= 1
					continue
				}
			}

			// pass when count zero
			if item.PurchaseCount == 0 {
				continue
			}

			// if it is not first buying
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
				singleton.InstanceLogger().Errs <- fmt.Errorf("%s 분봉이 잘못된 전략을 삭제합니다. 다시 생성해 주세요", item.CoinMarketName)
				singleton.InstanceBuyTargetItems().Items = append(singleton.InstanceBuyTargetItems().Items[:i], singleton.InstanceBuyTargetItems().Items[i+1:]...)
				singleton.SaveStrategyBuyTargetItems()

				// queue in deletion
				data := model.ItemCollectionForSocketNew()
				data.DeletedItemId = &item.ItemId
				singleton.InstanceItemsCollectionCh() <- data

				i -= 1
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
			price, err := order.GetLowestSellOrderBook(client, item.CoinMarketName)

			if err != nil {
				singleton.InstanceLogger().Errs <- err
				continue
			}

			// price requirements
			// before entering into action
			if price > lower {
				continue
			}

			// all requirements are satisfied. proceed with order
			buyAmountInKrw := price * item.DesiredBuyAmount
			buyAmountInKrw = math.Round(buyAmountInKrw)

			singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s를 %.4f가격에 %.8f(한화 : %f) 만큼 매수를 시도합니다.", item.CoinMarketName, price, item.DesiredBuyAmount, buyAmountInKrw)
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
			singleton.SaveStrategyBuyTargetItems()

			// apply krw, coin changes
			sendAllBalanceAndItem(client, item)

			if item.PurchaseCount == 0 {
				singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 코인 구매회수 소진되었습니다.", item.CoinMarketName)
			}

			// apply purchase count
			data := model.ItemCollectionForSocketNew()
			data.BuyStartegyItem = item
			singleton.InstanceItemsCollectionCh() <- data

			// if profit line and lossline 0, pass inserting sell detector bot
			if item.ProfitLinePercent == 0. && item.LossLinePercent == 0. {
				if item.PurchaseCount == 0 {
					singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 코인은 매수/매도 감시 미실행 대상으로 아이템을 삭제합니다.", item.CoinMarketName)
					data := model.ItemCollectionForSocketNew()
					data.DeletedItemId = &item.ItemId
					singleton.InstanceItemsCollectionCh() <- data
				}
				continue
			}

			// wait until order complete
			time.Sleep(time.Millisecond * 1000)
			orderedResult, _, err := client.GetOrder(orderResult.UUID, "")

			startTime := time.Now()
			for orderResult.ExecutedVolume == "" || err != nil {
				diff := time.Since(startTime)
				if diff > time.Second*10 {
					break
				}

				time.Sleep(time.Millisecond * 500)
				orderedResult, _, err = client.GetOrder(orderResult.UUID, "")
			}

			if orderResult.ExecutedVolume == "" {
				singleton.InstanceLogger().Errs <- fmt.Errorf("볼륨 취득에 실패했습니다. 판매 감시봇 진입 실패! #에러 발생 코인 이름: %s", item.CoinMarketName)
				if item.PurchaseCount == 0 {
					hasSellTargetItem := false
					for _, sellTargetItem := range singleton.InstanceSellTargetItems().BoughtItems {
						if item.ItemId == sellTargetItem.ItemId {
							hasSellTargetItem = true
						}
					}

					// case - there is no sell target item, and also consumed all purchased count.
					if !hasSellTargetItem {
						singleton.InstanceLogger().Errs <- fmt.Errorf("%s 볼륨 취득 실패 및 구매 횟수 소진으로 인해 아이템을 삭제합니다", item.CoinMarketName)
						singleton.InstanceBuyTargetItems().Items = append(singleton.InstanceBuyTargetItems().Items[:i], singleton.InstanceBuyTargetItems().Items[i+1:]...)
						singleton.SaveStrategyBuyTargetItems()
					}
				}
				continue
			}

			// check whether the item exists in sell target items.
			hasExistingItem := false

			for i := 0; i < len(singleton.InstanceSellTargetItems().BoughtItems); i++ {
				existingSellTargetItem := singleton.InstanceSellTargetItems().BoughtItems[i]

				// if item has same id
				if item.ItemId == existingSellTargetItem.ItemId && item.CoinMarketName == existingSellTargetItem.CoinMarketName {
					currentExecutedVolume, _ := converter.StringToFloatWithDigit(orderedResult.ExecutedVolume, 8)
					var currentExecutedPrice float64 = 0.

					for _, trade := range orderedResult.Trades {
						if item.CoinMarketName == trade.Market {
							currentExecutedPrice, _ = converter.StringToFloatWithDigit(trade.Price, 4)
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
					newLossTargetPrice := newAvgPrice - newAvgPrice*(item.LossLinePercent/100)

					newAvgPrice = converter.FloatToFloatwithDigit(newAvgPrice, 4)
					newExecutedVolume = converter.FloatToFloatwithDigit(newExecutedVolume, 8)
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
					sendKrwAndCoinBalance(client)
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
					currentExecutedPrice, _ = converter.StringToFloatWithDigit(trade.Price, 4)
				}
			}

			if currentExecutedPrice == 0. {
				singleton.InstanceLogger().Errs <- fmt.Errorf("트레이드 정보 취득 오류로 감시봇 진입 실패했습니다. #에러 발생 코인 이름: %s", item.CoinMarketName)
				continue
			}

			currentExecutedVolume, err := converter.StringToFloatWithDigit(orderedResult.ExecutedVolume, 8)
			if err != nil {
				singleton.InstanceLogger().Errs <- fmt.Errorf("볼륨 정보 취득 오류로 감시봇 진입 실패했습니다. #에러 발생 코인 이름: %s", item.CoinMarketName)
				continue
			}

			profitTargetPrice := converter.FloatToFloatwithDigit(currentExecutedPrice+currentExecutedPrice*(item.ProfitLinePercent/100), 4)
			lossTargetPrice := converter.FloatToFloatwithDigit(currentExecutedPrice-currentExecutedPrice*(item.LossLinePercent/100), 4)
			currentExecutedPrice = converter.FloatToFloatwithDigit(currentExecutedPrice, 4)
			currentExecutedVolume = converter.FloatToFloatwithDigit(currentExecutedVolume, 8)

			// when user don't want to sell with profit
			if item.ProfitLinePercent == 0. {
				profitTargetPrice = 0.
			}

			// when user don't want to sell with loss
			if item.LossLinePercent == 0. {
				lossTargetPrice = 0.
			}

			// if there is too small gap like BTT, + 0.0001 price
			if profitTargetPrice != 0. && profitTargetPrice == currentExecutedPrice {
				profitTargetPrice += 0.0001
			}

			if item.LossLinePercent != 0. && lossTargetPrice == currentExecutedPrice {
				lossTargetPrice -= 0.0001
			}

			// if don't have existing item, add new.
			newSellTargetItem := model.SellTargetStrategyItemInfo{
				ItemId:            item.ItemId,
				CoinMarketName:    item.CoinMarketName,
				AvgBuyPrice:       currentExecutedPrice,
				ExecutedVolume:    currentExecutedVolume,
				ProfitTargetPrice: profitTargetPrice,
				LossTargetPrice:   lossTargetPrice}

			singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems, &newSellTargetItem)
			singleton.SaveSellTargetStrategyItems()
			singleton.InstanceLogger().Msgs <- fmt.Sprintf("판매 감시 리스트 진입 완료 %+v", newSellTargetItem)
		}

	}
}

func StartSellDetectorBot(client *upbit.Upbit) {
	singleton.InstanceLogger().Msgs <- "판매 감시 봇 작동 시작."
	for {
		// whole cycle wait
		TheSellCycleOngoing = false
		time.Sleep(time.Millisecond * 5000)
		TheSellCycleOngoing = true

		if len(singleton.InstanceSellTargetItems().BoughtItems) == 0 {
			continue
		}

		dic := make(map[string]bool)
		for _, item := range singleton.InstanceBuyTargetItems().Items {
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
			if len(dic) != 0 {
				if _, ok := dic[sellTargetItem.ItemId]; !ok {
					singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 해당 코인이 목록에 전략에 존재하지 않아 판매 감시 대상에서 제외합니다.", sellTargetItem.CoinMarketName)
					singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems[:i], singleton.InstanceSellTargetItems().BoughtItems[i+1:]...)
					singleton.SaveSellTargetStrategyItems()
					i -= 1
					continue
				}
			}

			// take info whether sell target volume is smaller than the balance in the account
			accounts, _, err := client.GetAccounts()
			var hasCoinInAcc = true
			if err == nil {
				hasMatched := false
				for _, account := range accounts {
					if account.GetMarketID() == sellTargetItem.CoinMarketName {
						hasMatched = true

						accBalance, err := converter.StringToFloatWithDigit(account.Balance, 8)
						if err != nil {
							singleton.InstanceLogger().Errs <- fmt.Errorf("%s, #에러 발생 코인 이름: %s", err.Error(), sellTargetItem.CoinMarketName)
						}

						if accBalance < sellTargetItem.ExecutedVolume {
							singleton.InstanceLogger().Msgs <- fmt.Sprintf("전략 매도 잔고보다 현재 코인의 잔고가 더 낮아 현재 계좌 코인의 잔고로 재조정합니다. #코인 이름: %s, #전략 잔고: %.8f, #계좌 잔고 %.8f (마켓 매수라 가격 차이가 생길 시 발생)", sellTargetItem.CoinMarketName, sellTargetItem.ExecutedVolume, accBalance)
							sellTargetItem.ExecutedVolume = accBalance

							singleton.SaveSellTargetStrategyItems()
						}
						break
					}
				}

				if !hasMatched {
					hasCoinInAcc = false
				}
			}

			if !hasCoinInAcc {
				singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 해당 코인의 계좌 잔고가 존재하지 않아 판매 감시 대상에서 삭제합니다.", sellTargetItem.CoinMarketName)
				singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems[:i], singleton.InstanceSellTargetItems().BoughtItems[i+1:]...)
				singleton.SaveSellTargetStrategyItems()
				i -= 1
				continue
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
			if sellTargetItem.ProfitTargetPrice != 0. {
				price, err := order.GetHighestBuyOrderBook(client, sellTargetItem.CoinMarketName)
				if err != nil {
					singleton.InstanceLogger().Errs <- err
					continue
				}

				if price > sellTargetItem.ProfitTargetPrice {
					sellOrderInfo := model.SellOrderInfo{MarketName: sellTargetItem.CoinMarketName, Volume: sellTargetItem.ExecutedVolume}
					orderResult, err := order.SellOrder(client, &sellOrderInfo)

					if err != nil {
						singleton.InstanceLogger().Errs <- fmt.Errorf("%s #에러 발생 코인 이름: %s", err.Error(), sellTargetItem.CoinMarketName)
						continue
					}

					// delete from sell target coin
					singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems[:i], singleton.InstanceSellTargetItems().BoughtItems[i+1:]...)
					singleton.SaveSellTargetStrategyItems()
					singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 익절 완료, 매도 양: %.8f, 매도 가격: %s", sellTargetItem.CoinMarketName, sellTargetItem.ExecutedVolume, orderResult.Price)
					sendKrwAndCoinBalance(client)

					// buy strategy item loop
					for j := 0; j < len(singleton.InstanceBuyTargetItems().Items); j++ {
						if singleton.InstanceBuyTargetItems().Items[j] == nil {
							continue
						}

						// delete if count == 0
						if singleton.InstanceBuyTargetItems().Items[j].ItemId == sellTargetItem.ItemId {
							if singleton.InstanceBuyTargetItems().Items[j].PurchaseCount == 0 {
								singleton.InstanceBuyTargetItems().Items = append(singleton.InstanceBuyTargetItems().Items[:j], singleton.InstanceBuyTargetItems().Items[j+1:]...)
								singleton.SaveStrategyBuyTargetItems()

								// queue in delete
								data := model.ItemCollectionForSocketNew()
								data.DeletedItemId = &sellTargetItem.ItemId
								singleton.InstanceItemsCollectionCh() <- data
								sendKrwAndCoinBalance(client)

								singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 전략 매수, 매도 모두 완료되어 목록에서 삭제합니다. 실행된 볼륨 : %.8f, 가격 : %s 익절 실행가 : %.8f", sellTargetItem.CoinMarketName, sellTargetItem.ExecutedVolume, orderResult.Price, sellTargetItem.ProfitTargetPrice)

								break
							}
						}
					}

					continue
				}
			}

			// start sell detect!!
			if sellTargetItem.LossTargetPrice != 0. {
				price, err := order.GetHighestBuyOrderBook(client, sellTargetItem.CoinMarketName)
				if err != nil {
					singleton.InstanceLogger().Errs <- err
					continue
				}

				if price < sellTargetItem.LossTargetPrice {
					sellOrderInfo := model.SellOrderInfo{MarketName: sellTargetItem.CoinMarketName, Volume: sellTargetItem.ExecutedVolume}
					orderResult, err := order.SellOrder(client, &sellOrderInfo)

					if err != nil {
						singleton.InstanceLogger().Errs <- fmt.Errorf("%s #에러 발생 코인 이름: %s, 시도 볼륨: %.8f, 시도 현재 가격: %.4f", err.Error(), sellTargetItem.CoinMarketName, sellTargetItem.ExecutedVolume, price)
						continue
					}

					// delete from sell target coin
					singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems[:i], singleton.InstanceSellTargetItems().BoughtItems[i+1:]...)
					singleton.SaveSellTargetStrategyItems()
					singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 손절 완료, 매도 양: %.8f, 매도 가격: %s", sellTargetItem.CoinMarketName, sellTargetItem.ExecutedVolume, orderResult.Price)
					sendKrwAndCoinBalance(client)

					for j := 0; j < len(singleton.InstanceBuyTargetItems().Items); j++ {
						if singleton.InstanceBuyTargetItems().Items[j] == nil {
							continue
						}

						// delete if count == 0
						if singleton.InstanceBuyTargetItems().Items[j].ItemId == sellTargetItem.ItemId {
							if singleton.InstanceBuyTargetItems().Items[j].PurchaseCount == 0 {
								singleton.InstanceBuyTargetItems().Items = append(singleton.InstanceBuyTargetItems().Items[:j], singleton.InstanceBuyTargetItems().Items[j+1:]...)
								singleton.SaveStrategyBuyTargetItems()

								// queue in delete
								data := model.ItemCollectionForSocketNew()
								data.DeletedItemId = &sellTargetItem.ItemId
								singleton.InstanceItemsCollectionCh() <- data
								sendKrwAndCoinBalance(client)
								singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 전략 매수, 매도 모두 완료되어 목록에서 삭제합니다. 실행된 볼륨 : %.8f, 가격 : %s 손절 실행가 : %.8f", sellTargetItem.CoinMarketName, sellTargetItem.ExecutedVolume, orderResult.Price, sellTargetItem.LossTargetPrice)

								break
							}
						}
					}

					continue
				}
			}
			// item cycle wait
			time.Sleep(time.Millisecond * 500)
		}

	}
}

func sendKrwAndCoinBalance(client *upbit.Upbit) {
	singleton.RefreshAccount(client)
	coinbalances := model.CoinBalances{Balances: []*model.CoinBalance{}}
	for _, balance := range singleton.InstanceCoinBalances() {
		isSmall := checkSmallbalance(balance.AvgBuyPrice, balance.Balance)

		if isSmall {
			continue
		}

		coinBalance := model.CoinBalance{CoinName: balance.Currency, Balance: balance.Balance, AvgBuyPrice: balance.AvgBuyPrice}
		coinbalances.Balances = append(coinbalances.Balances, &coinBalance)
	}
	data := model.ItemCollectionForSocketNew()
	data.KrwBalanceItem = &model.KrwBalance{Balance: singleton.InstanceKrwBalance().Balance}
	data.CoinBalanceItem = &coinbalances
	singleton.InstanceItemsCollectionCh() <- data
}

func sendAllBalanceAndItem(client *upbit.Upbit, item *model.BuyStrategyItemInfo) {
	singleton.RefreshAccount(client)
	coinbalances := model.CoinBalances{Balances: []*model.CoinBalance{}}
	for _, balance := range singleton.InstanceCoinBalances() {
		isSmall := checkSmallbalance(balance.AvgBuyPrice, balance.Balance)

		if isSmall {
			continue
		}

		coinBalance := model.CoinBalance{CoinName: balance.Currency, Balance: balance.Balance, AvgBuyPrice: balance.AvgBuyPrice}
		coinbalances.Balances = append(coinbalances.Balances, &coinBalance)
	}
	data := model.ItemCollectionForSocketNew()
	data.KrwBalanceItem = &model.KrwBalance{Balance: singleton.InstanceKrwBalance().Balance}
	data.CoinBalanceItem = &coinbalances
	data.BuyStartegyItem = item
	singleton.InstanceItemsCollectionCh() <- data
}

func checkSmallbalance(avgBuyPrice string, coinBalance string) bool {
	buyPriceFloat, _ := converter.StringToFloatWithDigit(avgBuyPrice, 4)
	coinAmountFloat, _ := converter.StringToFloatWithDigit(coinBalance, 8)

	if buyPriceFloat*coinAmountFloat < 1000 {
		return true
	} else {
		return false
	}
}
