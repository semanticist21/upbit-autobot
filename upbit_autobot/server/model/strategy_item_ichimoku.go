package model

type BuyStrategyIchimokuItemInfos struct {
	Items []*BuyStrategyIchimokuItemInfo `json:"items"`
}

// Buy startegy Item info.
type BuyStrategyIchimokuItemInfo struct {
	Color               string  `json:"color"`
	ItemId              string  `json:"itemId"`
	CoinMarketName      string  `json:"coinMarketName"`
	ConversionLine      int     `json:"conversionLine"`
	PurchaseCount       int     `json:"purchaseCount"`
	ProfitLinePercent   float64 `json:"profitLinePercent"`
	LossLinePercent     float64 `json:"lossLinePercent"`
	LastBoughtTimestamp string  `json:"lastBoughtTimeStamp"`
	DesiredBuyAmount    float64 `json:"desiredBuyAmount"`
	CandleBaseMinute    int     `json:"candleBaseMinute"`
}
