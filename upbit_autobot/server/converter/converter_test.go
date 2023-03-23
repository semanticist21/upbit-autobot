package converter

import (
	"fmt"
	"testing"
)

func Test_StringToFloatRoundedString(t *testing.T) {
	result, _ := StringToFloatDigitString("3.11114", 2)
	fmt.Println(result)
}

func Test_StringToFloatWithDigit(t *testing.T) {
	result, _ := StringToFloatWithDigit("3.11114", 2)
	fmt.Println(result)
}
