package model

type Strategy struct {
	Minute        int
	Length        int
	Multiplier    float64
	LossPercent   float64
	ProfitPercent float64
}

func NewStartegy(
	minute int,
	length int,
	multiplier float64,
	loss float64,
	profit float64) *Strategy {
	return &Strategy{
		minute,
		length,
		multiplier,
		loss,
		profit,
	}
}

func DefaultStrategy() *Strategy {
	return &Strategy{
		60,
		20,
		2,
		5,
		5,
	}
}
