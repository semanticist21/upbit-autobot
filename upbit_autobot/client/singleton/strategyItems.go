package singleton

import (
	"encoding/json"
	"io"
	"io/ioutil"
	"os"
	"sync"

	"github.com/semanticist21/upbit-client-server/model"
)

var BuyTargetitems *model.StrategyItemInfos
var sellTargetitems *model.SellTargetStrategyItemInfos
var mutex sync.Mutex

//go:inline
func InstanceItems() *model.StrategyItemInfos {
	return BuyTargetitems
}

//go:inline
func InstanceSellTargetItems() *model.SellTargetStrategyItemInfos {
	return sellTargetitems
}

//go:inline
func SetInstanceItems(newItems *model.StrategyItemInfos) {
	dic := make(map[string]int)

	for idx, item := range BuyTargetitems.Items {
		dic[item.ItemId] = idx
	}

	for i := 0; i < len(newItems.Items); i++ {
		newItem := newItems.Items[i]

		if _, ok := dic[newItem.ItemId]; ok {
			newItems.Items[i] = BuyTargetitems.Items[dic[newItem.ItemId]]
		}
	}

	BuyTargetitems = newItems
	SaveStrategyItems()
}

var buyFileName = "items.json"
var sellFileName = "boughtItems.json"

//go:inline
func InitStrategyItems() {
	file, err := os.OpenFile(buyFileName, os.O_RDWR|os.O_CREATE, 0644)

	if err != nil {
		InstanceLogger().Errs <- err
		return
	}

	defer file.Close()
	bytes, err := io.ReadAll(file)

	if err != nil {
		InstanceLogger().Errs <- err
		return
	}

	if len(bytes) == 0 {
		BuyTargetitems = &model.StrategyItemInfos{}
		return
	}

	var saveditems *model.StrategyItemInfos

	marshalErr := json.Unmarshal(bytes, &saveditems)

	if marshalErr != nil {
		InstanceLogger().Errs <- err
	}

	BuyTargetitems = saveditems
}

//go:inline
func InitSellStrategyItems() {
	file, err := os.OpenFile(sellFileName, os.O_RDWR|os.O_CREATE, 0644)

	if err != nil {
		InstanceLogger().Errs <- err
		return
	}

	defer file.Close()
	bytes, err := io.ReadAll(file)

	if err != nil {
		InstanceLogger().Errs <- err
		return
	}

	if len(bytes) == 0 {
		return
	}

	err = json.Unmarshal(bytes, sellTargetitems)

	if err != nil {
		InstanceLogger().Errs <- err
		return
	}
}

//go:inline
func SaveStrategyItems() {
	mutex.Lock()
	saveInJson(BuyTargetitems, buyFileName)
	mutex.Unlock()
}

//go:inline
func SaveSellTargetStrategyItems() {
	mutex.Lock()
	saveInJson(sellTargetitems, sellFileName)
	mutex.Unlock()
}

//go:inline
func saveInJson(items interface{}, fileName string) {
	data, _ := json.Marshal(items)
	err := ioutil.WriteFile(fileName, data, 0644)

	if err != nil {
		InstanceLogger().Errs <- err
	}
}
