package model

type SellTargetStrategyItemInfos struct {
	BoughtItems []*SellTargetStrategyItemInfo `json:"boughtItems"`
}

// LossTargetPrice 0일 경우 실행 제외의 의미
// ProfitTargetPrice 0일 경우 실행 제외의 의미
type SellTargetStrategyItemInfo struct {
	ItemId            string  `json:"itemId"`
	CoinMarketName    string  `json:"coinMarketName"`
	AvgBuyPrice       float64 `json:"avgBuyPrice"`
	ExecutedVolume    float64 `json:"executedVolume"`
	ProfitTargetPrice float64 `json:"profitTargetPrice"`
	LossTargetPrice   float64 `json:"lossTargetPrice"`
}
