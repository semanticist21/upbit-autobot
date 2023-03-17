package main

import (
	"github.com/semanticist21/upbit-client-server/singleton"
)

func main() {
	// upbit get account balance
	// upbit := upbit.NewUpbit("", "")
	// u := upbit.NewUpbit("Hee9WfzADJ2PKtWoIz8qSXjah27MsU0twcQLLBoe", "")
	// result, _, err := u.GetAccounts()

	// if err != nil {
	// 	fmt.Println(err)
	// }

	// for _, item := range result {
	// 	fmt.Println(item.GetMarketID())
	// }

	// singleton.Init()

	singleton.Init()
	defer singleton.CloseWithDefer()
}
