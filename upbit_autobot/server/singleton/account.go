package singleton

import (
	"sync"

	"github.com/sangx2/upbit"
	"github.com/sangx2/upbit/model/exchange/account"
)

var krwAccount *account.Account
var coinAccounts []*account.Account
var mutexAcc sync.Mutex

func InstanceKrwBalance() *account.Account {
	return krwAccount
}

func InstanceCoinBalances() []*account.Account {
	return coinAccounts
}

func InitAccount(client *upbit.Upbit) {
	coinAccounts = []*account.Account{}
	RefreshAccount(client)
}

func RefreshAccount(client *upbit.Upbit) {
	mutexAcc.Lock()
	logger := InstanceLogger()
	accounts, _, err := client.GetAccounts()
	coinAccounts = []*account.Account{}

	if err != nil {
		logger.Errs <- err
		return
	}

	for _, account := range accounts {
		if account.Currency == "KRW" {
			krwAccount = account
		} else {
			coinAccounts = append(coinAccounts, account)
		}
	}
	mutexAcc.Unlock()

}
