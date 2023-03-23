package singleton

import (
	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/interfaces"
)

//go:inline
func Init() {
	// start logger
	InitLogger()
	logger.RunLogger()

	// get saved items
	InitStrategyItems()
	InitSellStrategyItems()
	InitItemsCh()
}

//go:inline
func InitWithClient(client *upbit.Upbit, cycleStarter interfaces.IStartInit) {
	InitAccount(client)
	cycleStarter.StartInit(client)
}

//go:inline
func CloseWithDefer() {
	InstanceLogger().LoggerWriter.Sync()
}
