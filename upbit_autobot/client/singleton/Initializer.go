package singleton

func Init() {
	// start upbit client
	InstanceClient()

	// start logger
	InitLogger()
	logger.RunLogger()

	// start fetching account balance
	InstanceAccount()
	// InitDetector()
}

//
func CloseWithDefer() {
	loggerWriter.Sync()
}
