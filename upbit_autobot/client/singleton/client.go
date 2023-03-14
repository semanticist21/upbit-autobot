package singleton

import (
	"sync"

	"github.com/sangx2/upbit"
)

var once = sync.Once{}
var client *upbit.Upbit

//go:inline
func InstanceClient() *upbit.Upbit {
	if client == nil {
		InitClient("", "")
	}

	return client
}

//go:inline
func InitClient(publicKey string, privateKey string) {
	once.Do(func() {
		client = upbit.NewUpbit(publicKey, privateKey)
	})
}
