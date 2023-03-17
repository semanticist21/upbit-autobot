package converter

import (
	"bytes"
	"encoding/base64"
	"strconv"
)

func Float64ToString(num float64) string {
	return strconv.FormatFloat(num, 'f', 2, 64)
}

func Float32ToString(num float32) string {
	return strconv.FormatFloat(float64(num), 'f', 3, 32)
}

func BufferTo64EncodeString(buf *bytes.Buffer) string {
	return base64.StdEncoding.EncodeToString(buf.Bytes())
}
