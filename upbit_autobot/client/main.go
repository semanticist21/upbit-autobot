package main

import (
	"fmt"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/singleton"
)

func main() {
	// upbit get account balance
	// upbit := upbit.NewUpbit("", "")
	u := upbit.NewUpbit("Hee9WfzADJ2PKtWoIz8qSXjah27MsU0twcQLLBoe", "tDo9oCvUbeXxfo21Fo44glBwxO9IHQBYrulkHtfK")
	result, _, err := u.GetAccounts()

	if err != nil {
		fmt.Println(err)
	}

	for _, item := range result {
		fmt.Println(item.GetMarketID())
	}

	singleton.Init()
}
