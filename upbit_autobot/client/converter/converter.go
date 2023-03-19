package converter

import (
	"bytes"
	"encoding/base64"
	"math"
	"strconv"
)

//go:inline
func Float64ToString(num float64, digit int) string {
	return strconv.FormatFloat(num, 'f', digit, 64)
}

//go:inline
func Float32ToString(num float32, digit int) string {
	return strconv.FormatFloat(float64(num), 'f', digit, 32)
}

//go:inline
func BufferTo64EncodeString(buf *bytes.Buffer) string {
	return base64.StdEncoding.EncodeToString(buf.Bytes())
}

//go:inline
func FloatStringToFloatRoundedString(str string, decimal int) (string, error) {
	num, err := strconv.ParseFloat(str, 64)
	if err != nil {
		return "", err
	}

	if decimal == 0 {
		return Float64ToString(math.Round(num), decimal), nil
	} else {
		return Float64ToString(math.Round(num*math.Pow(10, float64(decimal)))/math.Pow(10, float64(decimal)), decimal), nil
	}
}
