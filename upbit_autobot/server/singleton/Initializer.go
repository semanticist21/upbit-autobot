package singleton

import (
	"os"

	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/interfaces"
	"github.com/semanticist21/upbit-client-server/model"
)

func Init() {
	MakeTemplateFile()

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

func MakeTemplateFile() {
	_, err := os.Stat(model.FileName)

	if os.IsNotExist(err) {
		file, err := os.Create(model.FileName)
		if err != nil {
			InstanceLogger().Errs <- err
		}

		file.Close()
	}
}
