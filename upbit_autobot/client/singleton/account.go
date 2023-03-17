package singleton

import (
	"github.com/sangx2/upbit"
	"github.com/sangx2/upbit/model/exchange/account"
)

var krwAccount *account.Account
var coinsAccount []*account.Account

func InstanceAccount() *account.Account {
	return krwAccount
}

//go:inline
func InitAccount(client *upbit.Upbit) {
	coinsAccount = []*account.Account{}
	RefreshAccount(client)
}

//go:inline
func RefreshAccount(client *upbit.Upbit) {
	logger := InstanceLogger()
	accounts, _, err := client.GetAccounts()

	if err != nil {
		logger.Errs <- err
		return
	}

	for _, account := range accounts {
		if account.UnitCurrency == "KRW" {
			krwAccount = account

		} else {
			coinsAccount = append(coinsAccount, account)
		}
	}
}
