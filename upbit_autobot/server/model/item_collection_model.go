package model

type ItemCollectionForSocket struct {
	KrwBalanceItem   *KrwBalance          `json:"krwBalance"`
	CoinBalanceItem  *CoinBalances        `json:"coinBalance"`
	BuyStartegyItems *BuyStrategyItemInfo `json:"item"`
	DeletedItemId    *string              `josn:"deleteItemId"`
}

func ItemCollectionForSocketNew() *ItemCollectionForSocket {
	return &ItemCollectionForSocket{KrwBalanceItem: &KrwBalance{}, CoinBalanceItem: &CoinBalances{}, BuyStartegyItems: &BuyStrategyItemInfo{}, DeletedItemId: new(string)}
}
