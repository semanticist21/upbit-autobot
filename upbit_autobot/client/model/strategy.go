package model

import (
	"sync"
)

type Strategy struct {
	Minute         int
	Length         int
	Multiplier     float64
	LossPercent    float64
	ProfitPercent  float64
	PropotionToBuy float64
}

var once = &sync.Once{}
var currentStrategy *Strategy

func GetInstance() *Strategy {
	if currentStrategy == nil {
		once.Do(func() {
			currentStrategy = DefaultStrategy()
		})
	}

	return currentStrategy
}

func InitStrategy(
	minute int,
	length int,
	multiplier float64,
	loss float64,
	profit float64, proportionToBuy float64) *Strategy {
	return &Strategy{
		minute,
		length,
		multiplier,
		loss,
		profit,
		proportionToBuy,
	}
}

func DefaultStrategy() *Strategy {
	return &Strategy{
		60,
		20,
		2,
		5,
		5,
		10,
	}
}
