package model

type CoinBalances struct {
	Balances []*CoinBalance `json:"balances"`
}

type CoinBalance struct {
	CoinName    string `json:"coinName"`
	AvgBuyPrice string `json:"avgBuyPrice"`
	Balance     string `json:"balance"`
}
