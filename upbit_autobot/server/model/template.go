package model

import (
	"encoding/json"
	"io"
	"os"
)

type Template struct {
	BollingerTemplate *BuyStrategyItemInfo         `json:"bollingerTemplate"`
	IchimokuTemplate  *BuyStrategyIchimokuItemInfo `json:"ichimokuTemplate"`
}

var FileName string = "saves/template.json"

func SaveTemplate(bollingerItem *BuyStrategyItemInfo, ichimokuItem *BuyStrategyIchimokuItemInfo) error {
	bollingerItem.CoinMarketName = ""
	bollingerItem.LastBoughtTimestamp = ""
	ichimokuItem.CoinMarketName = ""
	ichimokuItem.LastBoughtTimestamp = ""

	template := Template{BollingerTemplate: bollingerItem, IchimokuTemplate: ichimokuItem}
	data, err := json.Marshal(&template)
	if err != nil {
		return err
	}

	os.WriteFile(FileName, data, 0644)
	return nil
}

func GetTemplate() (*Template, error) {
	var template *Template
	file, err := os.OpenFile(FileName, os.O_RDWR, 0644)
	if err != nil {
		return &Template{}, err
	}

	bytes, err := io.ReadAll(file)
	if err != nil {
		return &Template{}, err
	}

	err = json.Unmarshal(bytes, &template)
	if err != nil {
		return &Template{}, err
	}

	return template, nil
}

func GetTemplateBytes() ([]byte, error) {
	file, err := os.OpenFile(FileName, os.O_RDWR, 0644)
	if err != nil {
		return []byte{}, err
	}

	bytes, err := io.ReadAll(file)
	if err != nil {
		return []byte{}, err
	}

	return bytes, nil
}
