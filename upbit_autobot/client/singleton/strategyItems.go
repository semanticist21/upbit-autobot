package singleton

import (
	"encoding/json"
	"io"
	"io/ioutil"
	"os"

	"github.com/semanticist21/upbit-client-server/model"
)

var items *model.StrategyItemInfos
var sellTargetitems *model.StrategyItemInfos

//go:inline
func InstanceItems() *model.StrategyItemInfos {
	return items
}

//go:inline
func InstanceSellTargetItems() *model.StrategyItemInfos {
	return sellTargetitems
}

//go:inline
func SetInstanceItems(newItems *model.StrategyItemInfos) {
	dic := make(map[string]int)

	for idx, item := range items.Items {
		dic[item.ItemId] = idx
	}

	for i := 0; i < len(newItems.Items); i++ {
		newItem := newItems.Items[i]

		if _, ok := dic[newItem.ItemId]; ok {
			newItems.Items[i] = items.Items[dic[newItem.ItemId]]
		}
	}

	items = newItems
	SaveStrategyItems()
}

var fileName = "items.json"
var sellFileName = "boughtItems.json"

//go:inline
func InitStrategyItems() {
	file, err := os.OpenFile(fileName, os.O_RDWR|os.O_CREATE, 0644)

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
		items = &model.StrategyItemInfos{}
		return
	}

	var saveditems *model.StrategyItemInfos

	marshalErr := json.Unmarshal(bytes, &saveditems)

	if marshalErr != nil {
		InstanceLogger().Errs <- err
	}

	items = saveditems
}

//go:inline
func SaveStrategyItems() {
	data, _ := json.Marshal(items)
	err := ioutil.WriteFile(fileName, data, 0644)

	if err != nil {
		InstanceLogger().Errs <- err
	}
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
func SaveSellTargetStrategyItems() {
	data, _ := json.Marshal(sellTargetitems)
	err := ioutil.WriteFile(sellFileName, data, 0644)

	if err != nil {
		InstanceLogger().Errs <- err
	}
}
