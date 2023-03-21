package model

type StrategyItemInfos struct {
	Items []*StrategyItemInfo `json:"items"`
}

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
