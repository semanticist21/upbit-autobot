package singleton

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"sync"

	"github.com/semanticist21/upbit-client-server/model"
)

var buyTargetitems *model.BuyStrategyItemInfos
var sellTargetitems *model.SellTargetStrategyItemInfos
var mutex sync.Mutex

//go:inline
func InstanceBuyTargetItems() *model.BuyStrategyItemInfos {
	return buyTargetitems
}

//go:inline
func InstanceSellTargetItems() *model.SellTargetStrategyItemInfos {
	return sellTargetitems
}

//go:inline
func SetBuyTargetItemsInstance(newItems *model.BuyStrategyItemInfos) {
	dic := make(map[string]int)

	for idx, item := range buyTargetitems.Items {
		dic[item.ItemId] = idx
	}

	for i := 0; i < len(newItems.Items); i++ {
		newItem := newItems.Items[i]

		// items from client, if there are items which are in server too,
		// then replace with it.
		if _, ok := dic[newItem.ItemId]; ok {
			newItems.Items[i] = buyTargetitems.Items[dic[newItem.ItemId]]
		}
	}

	buyTargetitems = newItems
	SaveStrategyBuyTargetItems()
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
		buyTargetitems = &model.BuyStrategyItemInfos{Items: []*model.BuyStrategyItemInfo{}}
		return
	}

	var saveditems *model.BuyStrategyItemInfos

	marshalErr := json.Unmarshal(bytes, &saveditems)

	if marshalErr != nil {
		InstanceLogger().Errs <- err
	}

	buyTargetitems = saveditems
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
		sellTargetitems = &model.SellTargetStrategyItemInfos{BoughtItems: []*model.SellTargetStrategyItemInfo{}}
		return
	}

	err = json.Unmarshal(bytes, sellTargetitems)

	if err != nil {
		InstanceLogger().Errs <- err
		return
	}
}

//go:inline
func SaveStrategyBuyTargetItems() {
	fmt.Println("들어갔다")
	mutex.Lock()
	saveInJson(buyTargetitems, buyFileName)
	mutex.Unlock()
	fmt.Println("나왔다")
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
	err := os.WriteFile(fileName, data, 0644)

	if err != nil {
		InstanceLogger().Errs <- err
	}
}
