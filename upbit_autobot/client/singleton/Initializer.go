package singleton

func Init() {
	InstanceClient()
	InitLogger()

	InstanceAccount()
	InitDetector()
}
