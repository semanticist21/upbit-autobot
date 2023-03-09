package main

import (
	"fmt"

	"github.com/sangx2/upbit"
)

func main() {
	// u := upbit.NewUpbit(public, secret)
	u := upbit.NewUpbit("", "")

	minuteCandles, _, e := u.GetMinuteCandles("KRW-PUNDIX", "", "20", "60")
	if e != nil {
		fmt.Println(e)
	} else {
		arr := []float64{}
		for _, minuteCandle := range minuteCandles {
			// fmt.Printf("%+v", *minuteCandle)
			arr = append(arr, minuteCandle.TradePrice)
		}
	}
}
