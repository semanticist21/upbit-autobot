package bollinger

import "math"

//go:inline
func GetBollinger(multiplier float64, candles *[]float64) (float64, float64, float64) {
	sma := getSMA(candles)
	sd := getSD(candles)

	middle := sma
	upper := sma + multiplier*sd
	lower := sma - multiplier*sd

	return upper, middle, lower
}

//go:inline
func getSMA(candles *[]float64) float64 {
	sum := 0.

	for _, v := range *candles {
		sum += v
	}

	return sum / float64(len(*candles))
}

//go:inline
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
