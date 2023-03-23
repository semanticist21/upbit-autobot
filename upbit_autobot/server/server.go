package main

import (
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/converter"
	"github.com/semanticist21/upbit-client-server/detector"
	"github.com/semanticist21/upbit-client-server/model"
	"github.com/semanticist21/upbit-client-server/singleton"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		if r.Header.Get("password") == passwordKey {
			return true
		} else {
			return false
		}
	},
}

const (
	passwordKey string = "ca788859970da3ad18b0d2ceabdaf6d10e5a91edb10e2e7dc79268aefa54141f"
)

//go:inline
func startServer() {
	router := mux.NewRouter()
	router.HandleFunc("/login", originCheckingMiddleware(handleLogin))
	router.HandleFunc("/balance/{name}", originCheckingMiddleware(handleBalance))
	router.HandleFunc("/logs", originCheckingMiddleware(handleLogs))
	router.HandleFunc("/items", originCheckingMiddleware(handleItems))
	router.HandleFunc("/socket/logs", handleSocketLog)
	router.HandleFunc("/socket/items", handleSocketItems)
	http.Handle("/", router)
	http.ListenAndServe(":8080", nil)
}

//go:inline
func originCheckingMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		password := r.Header.Get("password")
		if password == passwordKey {
			next(w, r)
		} else {
			http.Error(w, "Forbidden", http.StatusForbidden)
		}
	}
}

//go:inline
func handleLogin(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		doGetHandleLogin(w, r)
	case http.MethodPost:
		doHandlePostLogin(w, r)
	}

}

func doGetHandleLogin(w http.ResponseWriter, r *http.Request) {
	file, err := getAccountFile()

	if err != nil {
		incurBadRequest(w, err.Error())
		return
	}

	bytes, err := io.ReadAll(file)

	if err != nil {
		incurBadRequest(w, err.Error())
		return
	}

	key := model.Key{}

	json.Unmarshal(bytes, &key)

	decryptedPublicStr, err := converter.DecryptString(key.PublicKey)
	if err != nil {
		incurBadRequest(w, err.Error())
		return
	}

	encryptedSecretStr, err := converter.DecryptString(key.SecretKey)
	if err != nil {
		incurBadRequest(w, err.Error())
		return
	}

	key.PublicKey = decryptedPublicStr
	key.SecretKey = encryptedSecretStr

	resultBytes, err := json.Marshal(&key)

	if err != nil {
		incurBadRequest(w, err.Error())
	}

	w.Header().Set("Content-Type", "applicaiton/json")
	w.Write(resultBytes)
}

func doHandlePostLogin(w http.ResponseWriter, r *http.Request) {
	// already logined case
	if singleton.InstanceClient() != nil {
		singleton.InstanceLogger().Msgs <- "이미 서버에 로그인되어있는 정보가 있습니다. 서버를 재시작하세요."
		incurBadRequestError(w)
		return
	}

	isSuccesful := false
	var keys *model.Key

	isSuccesful, keys = checkLogin(&w, r)
	queryBool := r.URL.Query().Get("isSave")

	if isSuccesful {
		singleton.InitClient(keys.PublicKey, keys.SecretKey)
		singleton.InitWithClient(singleton.InstanceClient(), &detector.CycleStarter{})
		w.WriteHeader(http.StatusOK)

		file, err := getAccountFile()

		if err != nil {
			singleton.InstanceLogger().Errs <- err
			return
		}

		defer file.Close()

		if queryBool == "true" {
			encryptedPublic, err := converter.EncryptString(keys.PublicKey)
			if err == nil {
				keys.PublicKey = encryptedPublic
			}

			encryptedSecret, err := converter.EncryptString(keys.SecretKey)
			if err == nil {
				keys.SecretKey = encryptedSecret
			}

			bytes, err := json.Marshal(keys)
			if err != nil {
				singleton.InstanceLogger().Errs <- err
				return
			}

			file.Write(bytes)
		} else {
			file.Truncate(0)
		}
	} else {
		w.WriteHeader(http.StatusBadRequest)

		if queryBool != "true" {
			file, err := getAccountFile()

			if err != nil {
				singleton.InstanceLogger().Errs <- err
				return
			}

			file.Truncate(0)
		}
	}
}

func getAccountFile() (*os.File, error) {
	fileName := "account.json"

	file, err := os.OpenFile(fileName, os.O_CREATE|os.O_RDWR, 0644)
	if err != nil {
		return nil, err
	}

	return file, nil
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
		avgBuyPrice, err := converter.StringToFloatDigitString(balance.AvgBuyPrice, 4)

		if err != nil {
			incurParseError(w)
			return
		}
		coinAmount, err := converter.StringToFloatDigitString(balance.Balance, 4)
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
			incurBadRequest(w, err.Error())
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
	data, err := json.Marshal(singleton.InstanceBuyTargetItems())

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
		return
	}

	data, err := io.ReadAll(r.Body)

	if err != nil {
		incurBadRequest(w, err.Error())
		return
	}

	item := model.BuyStrategyItemInfos{}

	marshalErr := json.Unmarshal(data, &item)

	if marshalErr != nil {
		singleton.InstanceLogger().Errs <- marshalErr
		return
	}

	singleton.SetBuyTargetItemsInstance(&item)
	singleton.InstanceLogger().Msgs <- "전략 아이템 저장되었습니다."
	w.WriteHeader(http.StatusOK)
}

//go:inline
func handleSocketLog(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}

	defer conn.Close()

	for {
		singleton.InstanceLogger().WriteLogReponse(conn)
	}
}

//go:inline
func handleSocketItems(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}

	defer conn.Close()

	for v := range singleton.InstanceItemsCollectionCh() {
		err := conn.WriteJSON(v)
		if err != nil {
			singleton.InstanceLogger().Errs <- err
		}
	}
}

//go:inline
func incurBadRequest(w http.ResponseWriter, msg string) {
	http.Error(w, msg, http.StatusBadRequest)
	singleton.InstanceLogger().Errs <- fmt.Errorf(msg)
}

//go:inline
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
