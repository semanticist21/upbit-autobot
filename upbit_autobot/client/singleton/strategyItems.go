package singleton

import (
	"encoding/json"
	"io/ioutil"
	"os"
)

type StrategyItemInfos struct {
	Items []*StrategyItemInfo `json:"items"`
}

var items *StrategyItemInfos

type StrategyItemInfo struct {
	Color               string  `json:"color"`
	ItemId              string  `json:"itemId"`
	CoinMarketName      string  `json:"coinMarketName"`
	BollingerLength     int     `json:"bollingerLength"`
	BollingerMultiplier int     `json:"bollingerMultiplier"`
	PurchaseCount       int     `json:"purchaseCount"`
	ProfitLine          float64 `json:"profitLine"`
	LossLine            float64 `json:"lossLine"`
	LastBoughtTimestamp string  `json:"lastBoughtTimeStamp"`
}

//go:inline
func InstanceItems() *StrategyItemInfos {
	return items
}

//go:inline
func SetInstanceItems(newItems *StrategyItemInfos) {
	items = newItems
	saveStrategyItems()
}

var fileName = "items.json"

//go:inline
func InitStrategyItems() {
	file, err := os.OpenFile(fileName, os.O_RDWR|os.O_CREATE, 0644)

	if err != nil {
		InstanceLogger().Errs <- err
		return
	}

	data, err := ioutil.ReadAll(file)

	if err != nil {
		InstanceLogger().Errs <- err
		return
	}

	if len(data) == 0 {
		return
	}

	var saveditems *StrategyItemInfos

	marshalErr := json.Unmarshal(data, &saveditems)

	if marshalErr != nil {
		InstanceLogger().Errs <- err
	}

	items = saveditems
}

//go:inline
func saveStrategyItems() {
	data, _ := json.Marshal(items)
	err := ioutil.WriteFile(fileName, data, 0644)

	if err != nil {
		InstanceLogger().Errs <- err
	}
}
