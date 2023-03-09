package coin

import (
	"fmt"
	"testing"

	"github.com/sangx2/upbit"
)

func TestCoin(t *testing.T) {
	u := upbit.NewUpbit("", "")

	result, _ := GetCoinNames(u)
	fmt.Println(len(result))
}

func TestGetCoinInfos(t *testing.T) {
	upbit := upbit.NewUpbit("", "")

	_, err := GetCoinInfosWithBollinger(upbit, nil)

	fmt.Println(err)
}
