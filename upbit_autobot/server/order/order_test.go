package order_test

import (
	"testing"

	"github.com/sangx2/upbit"
)

func Test_Order(t *testing.T) {
	client := upbit.NewUpbit("", "")
	mareket, _, _ := client.GetMarkets()

	for _, item := range mareket {
		t.Log(item)
	}
}
