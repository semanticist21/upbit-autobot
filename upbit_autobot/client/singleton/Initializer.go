package singleton

func Init() {
	// start logger
	InitLogger()
	logger.RunLogger()
}

func CloseWithDefer() {
	loggerWriter.Sync()
}
