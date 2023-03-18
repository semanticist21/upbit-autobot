package main

import (
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"strconv"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/converter"
	"github.com/semanticist21/upbit-client-server/model"
	"github.com/semanticist21/upbit-client-server/singleton"
)

//go:inline
func startServer() {
	http.HandleFunc("/login", handleLogin)
	http.HandleFunc("/balance", handleBalance)
	http.ListenAndServe(":8080", nil)
}

//go:inline
func handleLogin(w http.ResponseWriter, r *http.Request) {
	// already logined case
	if singleton.InstanceClient() != nil {
		w.WriteHeader(http.StatusOK)
	}

	isSuccesful := false
	var keys *model.Key

	if r.Method == http.MethodPost {
		isSuccesful, keys = checkLogin(&w, r)
	}

	if isSuccesful {
		singleton.InitClient(keys.PublicKey, keys.SecretKey)
		singleton.InitAccount(singleton.InstanceClient())
		w.WriteHeader(http.StatusOK)
	} else {
		w.WriteHeader(http.StatusBadRequest)
	}
}

//go:inline
func handleBalance(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	num, err := strconv.ParseFloat(singleton.InstanceKrwBalance().Balance, 64)

	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		singleton.InstanceLogger().Errs <- fmt.Errorf("failed to parse balance string to float64")
		return
	}

	roundedNum := math.Floor(num)
	stringNum := converter.Float64ToString(roundedNum)

	krwBalance := stringNum
	jsonKrw := model.Balance{Balance: krwBalance}

	data, err := json.Marshal(jsonKrw)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(data)
}

//go:inline
func checkLogin(w *http.ResponseWriter, r *http.Request) (bool, *model.Key) {

	body, err := io.ReadAll(r.Body)

	if err != nil {
		singleton.InstanceLogger().Errs <- err
		http.Error(*w, err.Error(), http.StatusBadRequest)
		return false, nil
	}

	if body == nil {
		return false, nil
	}

	keyObj := model.Key{}
	json.Unmarshal(body, &keyObj)
	isLogin := IsValidClientKey(keyObj.PublicKey, keyObj.SecretKey)

	return isLogin, &keyObj
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
