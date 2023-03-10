package singleton

import (
	"sync"

	"github.com/sangx2/upbit"
)

var once = sync.Once{}
var client *upbit.Upbit

func InstanceClient() *upbit.Upbit {
	return client
}

func InitClient(publicKey string, privateKey string) {
	once.Do(func() {
		client = upbit.NewUpbit(publicKey, privateKey)
	})
}
