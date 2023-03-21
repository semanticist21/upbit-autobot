package detector

import (
	"github.com/sangx2/upbit"
	"github.com/semanticist21/upbit-client-server/model"
)

var sellTargetitems *model.StrategyItemInfos

type CycleStarter struct {
}

func (starter *CycleStarter) StartInit(upbit *upbit.Upbit) {
	StartDetectorCycle(upbit)
}

//go:inline
func StartDetectorCycle(upbit *upbit.Upbit) {
	go StartBuyDetectorBot(upbit)
	go StartSellDetectorBot(upbit)
}

//go:inline
func StartBuyDetectorBot(upbit *upbit.Upbit) {

}

//go:inline
func StartSellDetectorBot(upbit *upbit.Upbit) {

}
