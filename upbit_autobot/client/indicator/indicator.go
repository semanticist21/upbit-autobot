package indicator

import (
	"math"
	"strconv"
	"time"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/model"
)

// used to determine to execute order or not.
type CoinBollingerInfo struct {
	Name       string
	Length     int
	Multiplier float64
	Current    float64
	Timestamp  time.Time
	Upper      float64
	Middle     float64
	Lower      float64
}

func NewBollinger(coinName string, strategy *model.Strategy, upbit *upbit.Upbit) (*CoinBollingerInfo, error) {
	candles := []float64{}
	minuteCandles, _, err := upbit.GetMinuteCandles(coinName, "", strconv.Itoa(strategy.Length), strconv.Itoa(strategy.Minute))
	if err != nil {
		return nil, err
	}

	currentPrice := 0.

	for i, v := range minuteCandles {
		if i == 0 {
			currentPrice = v.TradePrice
		}

		candles = append(candles, v.TradePrice)
	}

	upper, middle, lower := getBollinger(strategy.Multiplier, &candles)

	return &CoinBollingerInfo{
		coinName,
		len(candles),
		strategy.Multiplier,
		currentPrice,
		time.Now(),
		upper,
		middle,
		lower,
	}, nil
}

// private methods

func getBollinger(multiplier float64, candles *[]float64) (float64, float64, float64) {
	sma := getSMA(candles)
	sd := getSD(candles)

	middle := sma
	upper := sma + multiplier*sd
	lower := sma - multiplier*sd

	return upper, middle, lower
}

func getSMA(candles *[]float64) float64 {
	sum := 0.

	for _, v := range *candles {
		sum += v
	}

	return sum / float64(len(*candles))
}

func getSD(candles *[]float64) float64 {
	arr := []float64{}
	sum := 0.
	length := float64(len(*candles))

	for _, v := range *candles {
		arr = append(arr, v*v)
		sum += v
	}

	mean := sum / length
	meanSquared := mean * mean

	sumOfsquared := 0.

	for _, v := range arr {
		sumOfsquared += v
	}

	meanOfSqaured := sumOfsquared / length

	diff := meanOfSqaured - meanSquared
	diffRootSquared := math.Sqrt(diff)

	return diffRootSquared
}
