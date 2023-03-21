package main

import (
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/converter"
	"github.com/semanticist21/upbit-client-server/detector"
	"github.com/semanticist21/upbit-client-server/model"
	"github.com/semanticist21/upbit-client-server/singleton"
)

//go:inline
func startServer() {
	router := mux.NewRouter()
	router.HandleFunc("/login", handleLogin)
	router.HandleFunc("/balance/{name}", handleBalance)
	router.HandleFunc("/logs", handleLogs)
	router.HandleFunc("/items", handleItems)
	http.Handle("/", router)
	http.ListenAndServe(":8080", nil)
}

//go:inline
func handleLogin(w http.ResponseWriter, r *http.Request) {
	// already logined case
	if singleton.InstanceClient() != nil {
		return
	}

	isSuccesful := false
	var keys *model.Key

	if r.Method == http.MethodPost {
		isSuccesful, keys = checkLogin(&w, r)
	}

	if isSuccesful {
		singleton.InitClient(keys.PublicKey, keys.SecretKey)
		singleton.InitWithClient(singleton.InstanceClient(), &detector.CycleStarter{})
		w.WriteHeader(http.StatusOK)
	} else {
		w.WriteHeader(http.StatusBadRequest)
	}
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

//go:inline
func handleBalance(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	vars := mux.Vars(r)["name"]

	switch vars {
	case "krw":
		doKrwHandle(w, r)
	case "all":
		doAllHandle(w, r)
	}

}

//go:inline
func doKrwHandle(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		incurBadRequestError(w)
		return
	}

	num, err := strconv.ParseFloat(singleton.InstanceKrwBalance().Balance, 64)
	singleton.RefreshAccount(singleton.InstanceClient())

	if err != nil {
		incurParseError(w)
		return
	}

	roundedNum := math.Floor(num)
	stringNum := converter.Float64ToString(roundedNum, 0)

	krwBalance := stringNum
	jsonKrw := model.KrwBalance{Balance: krwBalance}

	data, err := json.Marshal(jsonKrw)
	if err != nil {
		incurMarshalError(w)
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(data)
	singleton.InstanceLogger().Msgs <- "원화 잔고내역 전송되었습니다."
}

//go:inline
func doAllHandle(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		incurBadRequestError(w)
		return
	}

	balances := singleton.InstanceCoinBalances()
	singleton.RefreshAccount(singleton.InstanceClient())

	coinBalances := &model.CoinBalances{}
	for _, balance := range balances {
		avgBuyPrice, err := converter.FloatStringToFloatRoundedString(balance.AvgBuyPrice, 2)

		if err != nil {
			incurParseError(w)
			return
		}
		coinAmount, err := converter.FloatStringToFloatRoundedString(balance.Balance, 4)
		if err != nil {
			incurParseError(w)
			return
		}

		if avgBuyPrice == "0.00" {
			continue
		}

		coinbalance := model.CoinBalance{CoinName: balance.Currency, AvgBuyPrice: avgBuyPrice, Balance: coinAmount}
		coinBalances.Balances = append(coinBalances.Balances, &coinbalance)
	}

	bytes, err := json.Marshal(coinBalances)

	if err != nil {
		incurMarshalError(w)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(bytes)
	singleton.InstanceLogger().Msgs <- "코인 구매내역 전송되었습니다."
}

//go:inline
func handleLogs(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		w.Header().Set("Content-Type", "application/json")
		w.Write(singleton.InstanceLogger().MsgQueue.Bytes())
		singleton.InstanceLogger().MsgQueue.Reset()
	case http.MethodPost:
		if r.Body == nil {
			incurBadRequestError(w)
			return
		}
		body, err := io.ReadAll(r.Body)

		if err != nil {
			singleton.InstanceLogger().Errs <- err
			incurBadRequestError(w)
			return
		}

		var log model.Log
		json.Unmarshal(body, &log)

		if log.Msg != "" {
			singleton.InstanceLogger().Msgs <- log.Msg
		}

		if log.ErrorMsg != "" {
			singleton.InstanceLogger().Errs <- fmt.Errorf(log.ErrorMsg)
		}
	}
}

//go:inline
func handleItems(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		// items update
		doGetHandleItems(w)
	case http.MethodPost:
		doPostHandleItems(w, r)
	}
}

//go:inline
func doGetHandleItems(w http.ResponseWriter) {
	// items update
	w.Header().Set("Content-Type", "application/json")
	data, err := json.Marshal(singleton.InstanceItems())

	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}

	w.Write(data)
	singleton.InstanceLogger().Msgs <- "전략 아이템 전송되었습니다."
}

//go:inline
func doPostHandleItems(w http.ResponseWriter, r *http.Request) {
	if r.Body == nil {
		incurBadRequestError(w)
	}

	data, err := io.ReadAll(r.Body)

	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}

	item := model.StrategyItemInfos{}

	marshalErr := json.Unmarshal(data, &item)

	if marshalErr != nil {
		singleton.InstanceLogger().Errs <- marshalErr
		return
	}

	singleton.SetInstanceItems(&item)
	singleton.InstanceLogger().Msgs <- "전략 아이템 저장되었습니다."
}

//go:inline
func incurBadRequest(w http.ResponseWriter, msg string) {
	w.WriteHeader(http.StatusBadRequest)
	singleton.InstanceLogger().Errs <- fmt.Errorf(msg)
}

//go:inlinincurBadRequestError
func incurBadRequestError(w http.ResponseWriter) {
	incurBadRequest(w, "the request is bad")
}

//go:inline
func incurParseError(w http.ResponseWriter) {
	incurBadRequest(w, "failed to parse balance string to float64")
}

//go:inline
func incurMarshalError(w http.ResponseWriter) {
	incurBadRequest(w, "failed to marshal data")
}
