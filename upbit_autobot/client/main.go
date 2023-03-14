package main

import "github.com/semanticist21/upbit-client-server/singleton"

func main() {
	// upbit get account balance
	// upbit := upbit.NewUpbit("", "")
	// u := upbit.NewUpbit("AccessKey", "SecretKey")

	singleton.Init()
}
