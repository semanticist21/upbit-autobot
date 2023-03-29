package indicator

import (
	"math"

	"github.com/sangx2/upbit/model/quotation"
)

func GetIchimokuConversionLine(candles []*quotation.Candle) float64 {
	highest := 0.
	lowest := math.MaxFloat64

	for _, candle := range candles {
		if candle.HighPrice > float64(highest) {
			highest = candle.HighPrice
		}

		if candle.LowPrice < float64(lowest) {
			lowest = candle.LowPrice
		}
	}

	return (highest + lowest) / 2
}
