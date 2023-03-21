package singleton

import (
	"encoding/json"
	"io/ioutil"
	"os"

	"github.com/semanticist21/upbit-client-server/model"
)

var items *model.StrategyItemInfos

//go:inline
func InstanceItems() *model.StrategyItemInfos {
	return items
}

//go:inline
func SetInstanceItems(newItems *model.StrategyItemInfos) {
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

	var saveditems *model.StrategyItemInfos

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
