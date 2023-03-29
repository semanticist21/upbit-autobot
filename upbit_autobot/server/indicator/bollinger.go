package indicator

import "math"

func GetBollinger(multiplier int, candles *[]float64) (float64, float64, float64) {
	sma := getSMA(candles)
	sd := getSD(candles)

	middle := sma
	upper := sma + float64(multiplier)*sd
	lower := sma - float64(multiplier)*sd

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
