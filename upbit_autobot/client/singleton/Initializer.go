package singleton

func Init() {
	// start logger
	InitLogger()
	logger.RunLogger()

	// get saved items
	InitStrategyItems()
}

func CloseWithDefer() {
	loggerWriter.Sync()
}
