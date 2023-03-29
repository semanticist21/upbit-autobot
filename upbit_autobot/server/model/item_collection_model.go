package model

type ItemCollectionForSocket struct {
	KrwBalanceItem          *KrwBalance          `json:"krwBalance"`
	CoinBalanceItem         *CoinBalances        `json:"coinBalance"`
	BuyStartegyItem         *BuyStrategyItemInfo `json:"item"`
	BuyStartegyIchimokuItem *BuyStrategyItemInfo `json:"ichimokuItem"`
	DeletedItemId           *string              `json:"deleteItemId"`
}

func ItemCollectionForSocketNew() *ItemCollectionForSocket {
	return &ItemCollectionForSocket{KrwBalanceItem: &KrwBalance{}, CoinBalanceItem: &CoinBalances{}, BuyStartegyItem: &BuyStrategyItemInfo{}, DeletedItemId: new(string)}
}
