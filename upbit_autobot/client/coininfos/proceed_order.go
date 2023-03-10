package coininfos

import (
	"fmt"
	"math"
	"strconv"
	"time"

	"github.com/sangx2/upbit"
	"github.com/sangx2/upbit/model/exchange"
	"github.com/sangx2/upbit/model/exchange/account"
	"github.com/semanticist21/upbit-client-server/indicator"
	"github.com/semanticist21/upbit-client-server/logger"
)

var accountInfo *account.Account
var currentKrw float64

// only when the current price is lower than Bollinger bottom level.
func ProceedOrder(upbit *upbit.Upbit, coinInfo indicator.CoinBollingerInfo) {
	// get the current balance
	if accountInfo == nil {
		fmt.Println("why it is executed everytime ????")
		accounts, _, err := upbit.GetAccounts()
		if err != nil {
			logger.GetInstance().InsertErr(err)
			return
		}

		for _, account := range accounts {
			if account.Currency == "KRW" {
				currentKrw, _ = strconv.ParseFloat(account.Balance, 64)
			}
		}
	}

	// strategy := model.GetInstance()
	buyAmount := currentKrw * 0.3

	// info
	chance, _, err := upbit.GetOrderChance(coinInfo.Name)
	if err != nil {
		logger.GetInstance().InsertErr(err)
		return
	}

	minvalueToBuy, _ := chance.Market.Bid.MinTotal.Float64()

	if minvalueToBuy > buyAmount {
		logger.GetInstance().InsertErr(fmt.Errorf("buy amount was not enough to execute a minimum order"))
		return
	}

	uuid := strconv.FormatInt(time.Now().UnixNano(), 10)

	fmt.Printf("currentkrw %.2f\n", currentKrw)
	fmt.Printf("buy amount %f\n", buyAmount/coinInfo.Current)
	fmt.Printf("name %s\n", coinInfo.Name)
	fmt.Printf("price %.2f\n", coinInfo.Current)

	order, _, err := upbit.PurchaseOrder(
		coinInfo.Name,
		"",
		strconv.FormatFloat(math.Round(buyAmount), 'f', -1, 64),
		// strconv.FormatFloat(coinInfo.Current, 'f', -1, 64),
		exchange.ORDER_TYPE_PRICE, uuid)

	if err != nil {
		logger.GetInstance().InsertErr(err)
		return
	}

	fmt.Printf("%+v\n", order)
}
