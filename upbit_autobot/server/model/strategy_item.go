package model

type BuyStrategyItemInfos struct {
	BollingerItems []*BuyStrategyItemInfo `json:"items"`
}

// Buy startegy Item info.
type BuyStrategyItemInfo struct {
	Color               string  `json:"color"`
	ItemId              string  `json:"itemId"`
	CoinMarketName      string  `json:"coinMarketName"`
	BollingerLength     int     `json:"bollingerLength"`
	BollingerMultiplier int     `json:"bollingerMultiplier"`
	PurchaseCount       int     `json:"purchaseCount"`
	ProfitLinePercent   float64 `json:"profitLinePercent"`
	LossLinePercent     float64 `json:"lossLinePercent"`
	LastBoughtTimestamp string  `json:"lastBoughtTimeStamp"`
	DesiredBuyAmount    float64 `json:"desiredBuyAmount"`
	CandleBaseMinute    int     `json:"candleBaseMinute"`
}
