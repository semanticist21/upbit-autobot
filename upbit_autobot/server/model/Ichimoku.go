package model

type Ichimoku struct {
	ConversionLinePeriod int
	BaseLinePeriod       int
	LaggingSpan2Period   int
	Displacement         int
}

func NewIchimoku() Ichimoku {
	return Ichimoku{
		ConversionLinePeriod: 0,
		BaseLinePeriod:       0,
		LaggingSpan2Period:   0,
		Displacement:         0,
	}
}
