package model

type VolumeInfo struct {
	Name        string  `json:"name"`
	Symbol      string  `json:"symbol"`
	TotalVolume float64 `json:"total_volume"`
}
