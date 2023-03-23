package main

import (
	"github.com/semanticist21/upbit-client-server/singleton"
)

func main() {
	// start instances
	singleton.Init()
	defer singleton.CloseWithDefer()
	singleton.InstanceLogger().Msgs <- "싱글톤 인스턴스 시작 완료."

	// start server
	singleton.InstanceLogger().Msgs <- "서버 시작. localhost:8080"
	startServer()
}
