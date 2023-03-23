package singleton

import (
	"fmt"
	"testing"
)

func TestLogger(t *testing.T) {
	InitLogger()
	logger.RunLogger()

	logger.Msgs <- "test"
	logger.Errs <- fmt.Errorf("error")
}
