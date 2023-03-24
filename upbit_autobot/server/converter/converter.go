package converter

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"io"
	"math"
	"strconv"
	"time"
)

func Float64ToString(num float64, digit int) string {
	return strconv.FormatFloat(num, 'f', digit, 64)
}

func Float32ToString(num float32, digit int) string {
	return strconv.FormatFloat(float64(num), 'f', digit, 32)
}

func BufferTo64EncodeString(buf *bytes.Buffer) string {
	return base64.StdEncoding.EncodeToString(buf.Bytes())
}

func StringToFloatDigitString(str string, decimal int) (string, error) {
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

func StringToFloatWithDigit(str string, decimal int) (float64, error) {
	num, err := strconv.ParseFloat(str, 64)
	if err != nil {
		return -1, err
	}

	if decimal == 0 {
		return math.Round(num), nil
	} else {
		return math.Round(num*math.Pow(10, float64(decimal))) / math.Pow(10, float64(decimal)), nil
	}
}

func FloatToFloatwithDigit(num float64, decimal int) float64 {
	if decimal == 0 {
		return math.Round(num)
	} else {
		return math.Round(num*math.Pow(10, float64(decimal))) / math.Pow(10, float64(decimal))
	}
}

var encyrptionToken []byte = []byte("+MbQeThWmZq4t7w!")

func EncryptString(str string) (string, error) {
	block, err := aes.NewCipher(encyrptionToken)

	if err != nil {
		return "", err
	}

	nonce := make([]byte, 12)
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return "", err
	}

	aesgcm, _ := cipher.NewGCM(block)
	cipherText := aesgcm.Seal(nonce, nonce, []byte(str), nil)

	return base64.StdEncoding.EncodeToString(cipherText), nil
}

func DecryptString(str string) (string, error) {
	cipherText, err := base64.StdEncoding.DecodeString(str)
	if err != nil {
		return "", err
	}

	block, err := aes.NewCipher(encyrptionToken)
	if err != nil {
		return "", err
	}

	if len(cipherText) < 12 {
		return "", fmt.Errorf("ciphertext too short")
	}

	nonce, cipherText := cipherText[:12], cipherText[12:]
	aesgcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	plainText, err := aesgcm.Open(nil, nonce, cipherText, nil)
	if err != nil {
		return "", err
	}
	return string(plainText), nil
}

func GetLayoutStrting() string {
	return "2006-01-02T15:04:05.000Z"
}

func NowToISO8601() string {
	now := time.Now()
	layout := GetLayoutStrting() // ISO8601 format layout string
	return now.UTC().Format(layout)

	//test code
	// result, _ := time.Parse("2006-01-02T15:04:05.000Z", nowToISO8601())
	// 		time.Sleep(30 * time.Second)
	// 		min := time.Since(result).Minutes()
	// 		fmt.Println("분봉 차이")
	// 		fmt.Printf("%f", min)
}

func Iso8601StringToTime(timeStamp string) (time.Time, error) {
	return time.Parse(GetLayoutStrting(), timeStamp)
}
