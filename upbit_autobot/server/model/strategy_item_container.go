package model

type StrategyItemContainer struct {
	BollingerItems *BuyStrategyItemInfos         `json:"bollingerItems"`
	IchimokuItems  *BuyStrategyIchimokuItemInfos `json:"ichimokuItems"`
}

func NewStrategyItemContainer(items *BuyStrategyItemInfos, ichimokuItems *BuyStrategyIchimokuItemInfos) StrategyItemContainer {
	return StrategyItemContainer{BollingerItems: items, IchimokuItems: ichimokuItems}
}
