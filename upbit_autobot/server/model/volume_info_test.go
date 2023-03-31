package model_test

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"testing"

	"github.com/semanticist21/upbit-client-server/model"
)

var url string = "http://api.coingecko.com/api/v3/coins/markets?vs_currency=krw&order=volume_desc&per_page=50&page=1&sparkline=false&price_change_percentage=24h"

func Test_volume(t *testing.T) {
	resp, err := http.Get(url)

	if err != nil {
		t.Log(err)
		return
	}

	bytes, err := io.ReadAll(resp.Body)

	if err != nil {
		t.Log(err)
		return
	}

	volumes := []*model.VolumeInfo{}
	err = json.Unmarshal(bytes, &volumes)

	fmt.Println(string(bytes))
	if err != nil {
		fmt.Println(err)
		return
	}

	t.Log(volumes)
}
