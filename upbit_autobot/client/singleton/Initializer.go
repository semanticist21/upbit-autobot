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
	InitStrategyItems()
}

func InitWithClient(upbit *upbit.Upbit, cycleStarter interfaces.IStartInit) {
	InitAccount(upbit)
	cycleStarter.StartInit(upbit)
}

func CloseWithDefer() {
	InstanceLogger().LoggerWriter.Sync()
}
