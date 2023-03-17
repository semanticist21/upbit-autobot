package main

import (
	"encoding/json"
	"io/ioutil"
	"net/http"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/model"
	"github.com/semanticist21/upbit-client-server/singleton"
)

func StartServer() {
	http.HandleFunc("/login", handleLogin)

	http.ListenAndServe(":8080", nil)
}

func handleLogin(w http.ResponseWriter, r *http.Request) {
	isSuccesful := false

	if r.Method == http.MethodPost {
		isSuccesful = checkLogin(r)
	}

	if isSuccesful {
		w.WriteHeader(http.StatusOK)
	} else {
		w.WriteHeader()
	}

	// w.Header().Set("Content-Type", "application/json")

	// tokenStr := r.Body
}

func checkLogin(r *http.Request) bool {

	body, err := ioutil.ReadAll(r.Body)

	if err != nil {
		singleton.InstanceLogger().Errs <- err
		return false
	}

	keyObj := model.Key{}
	json.Unmarshal(body, keyObj)
	isLogin := IsValidClientKey(keyObj.PublicKey, keyObj.SecretKey)

	return isLogin
}

//go:inline
func IsValidClientKey(publicKey string, secretKey string) bool {
	client := upbit.NewUpbit(publicKey, secretKey)
	_, _, err := client.GetAccounts()

	if err != nil {
		return false
	} else {
		return true
	}
}
