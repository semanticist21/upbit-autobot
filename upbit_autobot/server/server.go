package main

import (
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/converter"
	"github.com/semanticist21/upbit-client-server/detector"
	"github.com/semanticist21/upbit-client-server/model"
	"github.com/semanticist21/upbit-client-server/order"
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

var isItemWriting = false
var reqChannel chan *model.ClientRequest

func startServer() {
	go goWithRequest()

	router := mux.NewRouter()
	router.HandleFunc("/login", originCheckingMiddleware(handleLogin))
	router.HandleFunc("/balance/{name}", originCheckingMiddleware(handleBalance))
	router.HandleFunc("/logs", originCheckingMiddleware(handleLogs))
	router.HandleFunc("/items", originCheckingMiddleware(handleItems))
	router.HandleFunc("/template", originCheckingMiddleware(handleTemplate))
	router.HandleFunc("/socket/logs", handleSocketLog)
	router.HandleFunc("/socket/items", handleSocketItems)
	http.Handle("/", router)

	if err := http.ListenAndServe("localhost:8080", nil); err != nil {
		singleton.InstanceLogger().Errs <- err
	}

}

func originCheckingMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		password := r.Header.Get("password")
		if password != passwordKey {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		// when passed request verification
		var req = model.ClientRequest{}
		req.W = w
		req.R = r
		req.Done = make(chan struct{})
		req.Function = next
		reqChannel <- &req
		<-req.Done
	}
}

func goWithRequest() {
	reqChannel = make(chan *model.ClientRequest)

	for req := range reqChannel {
		req.Function(req.W, req.R)
		close(req.Done)
	}
}

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

	// 빈 값인 경우
	if key.PublicKey == "" && key.SecretKey == "" {
		w.WriteHeader(http.StatusOK)
		return
	}

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
		singleton.InstanceLogger().Msgs <- "로그인 완료 !!"

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

			defer file.Close()

			file.Truncate(0)
		}
	}
}

func getAccountFile() (*os.File, error) {
	fileName := "saves/account.json"

	file, err := os.OpenFile(fileName, os.O_CREATE|os.O_RDWR, 0644)
	if err != nil {
		return nil, err
	}

	return file, nil
}

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

func IsValidClientKey(publicKey string, secretKey string) bool {
	client := upbit.NewUpbit(publicKey, secretKey)
	_, _, err := client.GetAccounts()

	if err != nil {
		return false
	} else {
		return true
	}
}

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
	default:
		if vars != "" {
			doIndividualCoinHandle(w, r, vars)
		} else {
			w.WriteHeader(http.StatusBadRequest)
		}
	}

}

func doKrwHandle(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		incurBadRequestError(w)
		return
	}

	if singleton.InstanceKrwBalance() == nil {
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

func doAllHandle(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		incurBadRequestError(w)
		return
	}

	balances := singleton.InstanceCoinBalances()
	if balances == nil {
		incurBadRequestError(w)
		return
	}
	singleton.RefreshAccount(singleton.InstanceClient())

	coinBalances := &model.CoinBalances{}
	for _, balance := range balances {
		avgBuyPrice, err := converter.StringToFloatDigitString(balance.AvgBuyPrice, 4)

		if err != nil {
			incurParseError(w)
			return
		}
		coinAmount, err := converter.StringToFloatDigitString(balance.Balance, 8)
		if err != nil {
			incurParseError(w)
			return
		}

		if avgBuyPrice == "0.00" {
			continue
		}

		buyPriceFloat, _ := converter.StringToFloatWithDigit(avgBuyPrice, 4)
		coinAmountFloat, _ := converter.StringToFloatWithDigit(coinAmount, 8)

		if buyPriceFloat*coinAmountFloat < 1000 {
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

func doIndividualCoinHandle(w http.ResponseWriter, r *http.Request, coinMarketname string) {
	markets, _, err := singleton.InstanceClient().GetMarkets()
	marketMap := make(map[string]bool)

	if err != nil {
		singleton.InstanceLogger().Errs <- fmt.Errorf("마켓 정보 조회 중 오류 발생 %s", err.Error())
	} else {
		for _, market := range markets {
			marketMap[market.Market] = true
		}
	}

	if len(marketMap) != 0 {
		if _, ok := marketMap[coinMarketname]; !ok {
			w.WriteHeader(http.StatusOK)
			return
		}
	}

	price, err := order.GetCurrentPrice(singleton.InstanceClient(), coinMarketname)
	if err != nil {
		singleton.InstanceLogger().Errs <- err
		return
	}

	coinbalance := model.CoinBalance{CoinName: coinMarketname, AvgBuyPrice: converter.Float64ToString(price, 4), Balance: strconv.Itoa(0)}
	bytes, err := json.Marshal(coinbalance)

	if err != nil {
		incurMarshalError(w)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(bytes)
}

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

func handleTemplate(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		// items update
		doGetHandleTemplate(w)
	case http.MethodPost:
		doPostHandleTemplate(w, r)
	}
}

func doGetHandleTemplate(w http.ResponseWriter) {
	bytes, err := model.GetTemplateBytes()
	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(bytes)
}

func doPostHandleTemplate(w http.ResponseWriter, r *http.Request) {
	if r.Body == nil {
		incurBadRequestError(w)
		return
	}

	data, err := io.ReadAll(r.Body)

	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}

	template, err := model.GetTemplate()
	newTemplate := model.Template{}

	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}

	marshalErr := json.Unmarshal(data, &newTemplate)

	if marshalErr != nil {
		singleton.InstanceLogger().Errs <- marshalErr
		incurBadRequestError(w)
		return
	}

	if newTemplate.BollingerTemplate != nil && newTemplate.BollingerTemplate.CoinMarketName == "save" {
		template.BollingerTemplate = newTemplate.BollingerTemplate
	}

	if newTemplate.IchimokuTemplate != nil && newTemplate.IchimokuTemplate.CoinMarketName == "save" {
		template.IchimokuTemplate = newTemplate.IchimokuTemplate
	}

	if template.BollingerTemplate == nil {
		template.BollingerTemplate = &model.BuyStrategyItemInfo{}
		template.BollingerTemplate.CoinMarketName = ""
		template.BollingerTemplate.LastBoughtTimestamp = ""
	}

	if template.IchimokuTemplate == nil {
		template.IchimokuTemplate = &model.BuyStrategyIchimokuItemInfo{}
		template.IchimokuTemplate.CoinMarketName = ""
		template.IchimokuTemplate.LastBoughtTimestamp = ""
	}

	model.SaveTemplate(template.BollingerTemplate, template.IchimokuTemplate)
	singleton.InstanceLogger().Msgs <- "템플릿 저장되었습니다."
}

func handleItems(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		// items update
		doGetHandleItems(w)
	case http.MethodPost:
		doPostHandleItems(w, r)
	}
}

func doGetHandleItems(w http.ResponseWriter) {
	// items update
	w.Header().Set("Content-Type", "application/json")
	data, err := json.Marshal(model.NewStrategyItemContainer(singleton.InstanceBuyTargetItems(), singleton.InstanceBuyTargetIchimokuItems()))

	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}

	w.Write(data)
	singleton.InstanceLogger().Msgs <- "전략 아이템 전송되었습니다."
}

func doPostHandleItems(w http.ResponseWriter, r *http.Request) {
	if isItemWriting {
		singleton.InstanceLogger().Msgs <- "잠시 후 저장 다시 시도해주세요."
	}

	isItemWriting = true
	defer func() { isItemWriting = false }()

	if r.Body == nil {
		incurBadRequestError(w)
		return
	}

	data, err := io.ReadAll(r.Body)

	if err != nil {
		incurBadRequest(w, err.Error())
		return
	}

	sentItems := model.StrategyItemContainer{}
	marshalErr := json.Unmarshal(data, &sentItems)

	if marshalErr != nil {
		singleton.InstanceLogger().Errs <- marshalErr
		return
	}

	newItemsDic := make(map[string]bool)
	for _, item := range sentItems.BollingerItems.Items {
		newItemsDic[item.ItemId] = true
	}
	for _, item := range sentItems.IchimokuItems.Items {
		newItemsDic[item.ItemId] = true
	}

	existingItemsDic := make(map[string]bool)
	for _, item := range singleton.InstanceBuyTargetItems().Items {
		existingItemsDic[item.ItemId] = true
	}
	for _, item := range singleton.InstanceBuyTargetIchimokuItems().Items {
		existingItemsDic[item.ItemId] = true
	}

	for detector.TheBuyCycleOngoing && detector.TheSellCycleOngoing && detector.TheIchimokuCycleOngoing {
		time.Sleep(time.Millisecond * 500)
		if !detector.TheBuyCycleOngoing && !detector.TheSellCycleOngoing && !detector.TheIchimokuCycleOngoing {
			break
		}
	}

	//delete if on selltarget item
	for i := 0; i < len(singleton.InstanceSellTargetItems().BoughtItems); i++ {
		sellTargetItem := singleton.InstanceSellTargetItems().BoughtItems[i]
		if sellTargetItem == nil {
			continue
		}

		// if items exists for current items, but not for new item.
		// means this item is deleted.
		if _, ok := existingItemsDic[sellTargetItem.ItemId]; ok {
			if _, ok := newItemsDic[sellTargetItem.ItemId]; !ok {
				singleton.InstanceSellTargetItems().BoughtItems = append(singleton.InstanceSellTargetItems().BoughtItems[:i], singleton.InstanceSellTargetItems().BoughtItems[i+1:]...)
				singleton.InstanceLogger().Msgs <- fmt.Sprintf("%s 삭제된 저장 전략 아이템 매도 감시 목록에서 제거되었습니다.", sellTargetItem.CoinMarketName)
				continue
			}
		}
	}

	singleton.SetBuyTargetItemsInstance(sentItems.BollingerItems)
	singleton.SetBuyTargetItemsIchimokuInstance(sentItems.IchimokuItems)
	// singleton.InstanceLogger().Msgs <- "전략 아이템 저장되었습니다."
	w.WriteHeader(http.StatusOK)
}

func handleSocketLog(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}

	defer conn.Close()

	for {
		time.Sleep(time.Millisecond * 200)
		singleton.InstanceLogger().WriteLogReponse(conn)
	}
}

func handleSocketItems(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		singleton.InstanceLogger().Errs <- err
		incurBadRequestError(w)
		return
	}

	defer conn.Close()

	go func() {
		for {
			time.Sleep(time.Second * 1000)
		}
	}()

	for v := range singleton.InstanceItemsCollectionCh() {
		err := conn.WriteJSON(v)
		if err != nil {
			singleton.InstanceLogger().Errs <- err
		}
	}
}

func incurBadRequest(w http.ResponseWriter, msg string) {
	http.Error(w, msg, http.StatusBadRequest)
	singleton.InstanceLogger().Errs <- fmt.Errorf(msg)
}

func incurBadRequestError(w http.ResponseWriter) {
	incurBadRequest(w, "the request is bad")
}

func incurParseError(w http.ResponseWriter) {
	incurBadRequest(w, "failed to parse balance string to float64")
}

func incurMarshalError(w http.ResponseWriter) {
	incurBadRequest(w, "failed to marshal data")
}
