package main

import (
	"github.com/semanticist21/upbit-client-server/singleton"
)

func main() {
	// upbit get account balance
	// upbit := upbit.NewUpbit("", "")
	// u := upbit.NewUpbit("", "")
	// result, _, err := u.GetAccounts()

	// if err != nil {
	// 	fmt.Println(err)
	// }

	// for _, item := range result {
	// 	fmt.Println(item.GetMarketID())
	// }

	startServer()

	// start instances
	singleton.Init()
	defer singleton.CloseWithDefer()

}
