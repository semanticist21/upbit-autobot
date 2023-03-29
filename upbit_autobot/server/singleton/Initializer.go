package singleton

import (
	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/interfaces"
)

func Init() {
	// start logger
	InitLogger()
	logger.RunLogger()

	// get saved items
	InitStrategyItemsAll()
	InitSellStrategyItems()
	InitItemsCh()
}

func InitWithClient(client *upbit.Upbit, cycleStarter interfaces.IStartInit) {
	InitAccount(client)
	cycleStarter.StartInit(client)
}

func CloseWithDefer() {
	InstanceLogger().LoggerWriter.Sync()
}
