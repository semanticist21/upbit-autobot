package converter

import "strconv"

func Float64ToString(num float64) string {
	return strconv.FormatFloat(num, 'f', 2, 64)
}

func Float32ToString(num float32) string {
	return strconv.FormatFloat(float64(num), 'f', 3, 32)
}
