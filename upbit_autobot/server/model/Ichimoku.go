package model

type Ichimoku struct {
	ConversionLinePeriod int `json:"conversionLinePeriod"`
	BaseLinePeriod       int `json:"baseLinePeriod"`
	LaggingSpan2Period   int `json:"laggingSpan2Period"`
	Displacement         int `json:"displacement"`
}

func NewIchimoku() Ichimoku {
	return Ichimoku{
		ConversionLinePeriod: 0,
		BaseLinePeriod:       0,
		LaggingSpan2Period:   0,
		Displacement:         0,
	}
}
