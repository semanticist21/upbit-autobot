package model

import "net/http"

type ClientRequest struct {
	R        *http.Request
	W        http.ResponseWriter
	Done     chan struct{}
	Function func(w http.ResponseWriter, r *http.Request)
}
