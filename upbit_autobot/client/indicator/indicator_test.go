package indicator

import (
	"fmt"
	"testing"
)

func TestSma(t *testing.T) {
	a := []float64{120, 155, 130, 120, 111, 135, 122, 111}
	result := getSMA(&a)

	fmt.Println(result)
	t.Log(result)
}

func TestSd(t *testing.T) {
	a := []float64{120, 155, 130, 120, 111, 135, 122, 111}
	result := getSD(&a)

	fmt.Println(result)
}

func TestBollinger(t *testing.T) {
	// a := []float64{120, 155, 130, 120, 111, 135, 122, 111}
	// // bollinger := *NewBollinger(2, &a)

	// fmt.Println(bollinger)
}
