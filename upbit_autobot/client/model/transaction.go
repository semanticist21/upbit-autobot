package model

import "time"

type Transaction struct {
	Id         float64
	CoinName   string
	Quantity   float64
	OrderPrice float64
	HasBought  bool
	Strategy   Strategy
}

func NewTransaction(name string, quantity float64, price float64, strategy Strategy) *Transaction {
	return &Transaction{
		float64(time.Now().UnixNano()),
		name,
		quantity,
		price,
		false,
		strategy,
	}
}
