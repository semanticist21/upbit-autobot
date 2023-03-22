package model

type SellTargetStrategyItemInfos struct {
	Items []*SellTargetStrategyItemInfo `json:"items"`
}

type SellTargetStrategyItemInfo struct {
	Color               string  `json:"color"`
	ItemId              string  `json:"itemId"`
	CoinMarketName      string  `json:"coinMarketName"`
	BollingerLength     int     `json:"bollingerLength"`
	BollingerMultiplier int     `json:"bollingerMultiplier"`
	PurchaseCount       int     `json:"purchaseCount"`
	ProfitLine          float64 `json:"profitLine"`
	LossLine            float64 `json:"lossLine"`
	LastBoughtTimestamp string  `json:"lastBoughtTimeStamp"`
	DesiredBuyAmount    float64 `json:"desiredBuyAmount"`
	CandleBaseMinute    int     `json:"candleBaseMinute"`
}
