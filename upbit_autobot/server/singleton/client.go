package singleton

import (
	"github.com/sangx2/upbit"
)

// var once = sync.Once{}
var client *upbit.Upbit

func InstanceClient() *upbit.Upbit {
	return client
}

func InitClient(publicKey string, secretKey string) {
	client = upbit.NewUpbit(publicKey, secretKey)
}
