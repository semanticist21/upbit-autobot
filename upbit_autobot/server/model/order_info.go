package model

type BuyOrderInfo struct {
	MarketName     string
	BuyAmountInKrw float64
}

type SellOrderInfo struct {
	MarketName string
	Volume     float64
}
