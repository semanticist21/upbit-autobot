package singleton

import (
	"encoding/json"
	"io"
	"os"
	"sync"

	"github.com/semanticist21/upbit-client-server/model"
)

var buyTargetItems *model.BuyStrategyItemInfos
var buyTargetIchimokuItems *model.BuyStrategyIchimokuItemInfos
var sellTargetItems *model.SellTargetStrategyItemInfos
var mutex sync.Mutex

func InstanceBuyTargetItems() *model.BuyStrategyItemInfos {
	return buyTargetItems
}

func InstanceSellTargetItems() *model.SellTargetStrategyItemInfos {
	return sellTargetItems
}

func InstanceBuyTargetIchimokuItems() *model.BuyStrategyIchimokuItemInfos {
	return buyTargetIchimokuItems
}

func SetBuyTargetItemsInstance(newItems *model.BuyStrategyItemInfos) {
	dic := make(map[string]int)

	for idx, item := range buyTargetItems.Items {
		dic[item.ItemId] = idx
	}

	for i := 0; i < len(newItems.Items); i++ {
		newItem := newItems.Items[i]

		// items from client, if there are items which are in server too,
		// then replace with it.
		if _, ok := dic[newItem.ItemId]; ok {
			newItems.Items[i] = buyTargetItems.Items[dic[newItem.ItemId]]
		}
	}

	buyTargetItems = newItems
	SaveStrategyBuyTargetItems()
}

func SetBuyTargetItemsIchimokuInstance(newItems *model.BuyStrategyIchimokuItemInfos) {
	dic := make(map[string]int)

	for idx, item := range buyTargetIchimokuItems.Items {
		dic[item.ItemId] = idx
	}

	for i := 0; i < len(newItems.Items); i++ {
		newItem := newItems.Items[i]

		// items from client, if there are items which are in server too,
		// then replace with it.
		if _, ok := dic[newItem.ItemId]; ok {
			newItems.Items[i] = buyTargetIchimokuItems.Items[dic[newItem.ItemId]]
		}
	}

	buyTargetIchimokuItems = newItems
	SaveStrategyBuyTargetIchimokuItems()
}

var buyFileName = "saves/items.json"
var buyIchimokuFileName = "saves/items_ichimoku.json"
var sellFileName = "saves/boughtItems.json"

func InitStrategyItemsAll() {
	MakeFolder()
	InitStrategyIchimokuItems()
	InitStrategyItems()
}

func MakeFolder() {
	dir := "saves"

	err := os.MkdirAll(dir, 0755)
	if err != nil {
		InstanceLogger().Errs <- err
	}
}

func InitStrategyIchimokuItems() {
	file, err := os.OpenFile(buyIchimokuFileName, os.O_RDWR|os.O_CREATE, 0644)

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
		buyTargetIchimokuItems = &model.BuyStrategyIchimokuItemInfos{Items: []*model.BuyStrategyIchimokuItemInfo{}}
		return
	}

	var saveditems *model.BuyStrategyIchimokuItemInfos

	marshalErr := json.Unmarshal(bytes, &saveditems)

	if marshalErr != nil {
		InstanceLogger().Errs <- err
		saveditems = &model.BuyStrategyIchimokuItemInfos{}
		return
	}

	buyTargetIchimokuItems = saveditems
}

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
		buyTargetItems = &model.BuyStrategyItemInfos{Items: []*model.BuyStrategyItemInfo{}}
		return
	}

	var saveditems *model.BuyStrategyItemInfos

	marshalErr := json.Unmarshal(bytes, &saveditems)

	if marshalErr != nil {
		InstanceLogger().Errs <- err
		saveditems = &model.BuyStrategyItemInfos{}
		return
	}

	buyTargetItems = saveditems

}

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
		sellTargetItems = &model.SellTargetStrategyItemInfos{BoughtItems: []*model.SellTargetStrategyItemInfo{}}
		return
	}
	var savedItems *model.SellTargetStrategyItemInfos

	err = json.Unmarshal(bytes, &savedItems)

	if err != nil {
		InstanceLogger().Errs <- err
		panic("can't initialize sell items")
	}

	sellTargetItems = savedItems
}

func SaveStrategyBuyTargetItems() {
	mutex.Lock()
	saveInJson(buyTargetItems, buyFileName)
	mutex.Unlock()
}

func SaveSellTargetStrategyItems() {
	mutex.Lock()
	saveInJson(sellTargetItems, sellFileName)
	mutex.Unlock()
}

func SaveStrategyBuyTargetIchimokuItems() {
	mutex.Lock()
	saveInJson(buyTargetIchimokuItems, buyIchimokuFileName)
	mutex.Unlock()
}

func saveInJson(items interface{}, fileName string) {
	data, _ := json.Marshal(items)
	err := os.WriteFile(fileName, data, 0644)

	if err != nil {
		InstanceLogger().Errs <- err
	}
}
