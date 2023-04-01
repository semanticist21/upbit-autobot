package model

import "strconv"

type VolumeInfo struct {
	Symbol      string `json:"symbol"`
	TotalVolume string `json:"quoteVolume"`
}

type VolumeInfos []*VolumeInfo

func (s VolumeInfos) Len() int {
	return len(s)
}

// actually here, it is vice-versa to position big volume first in the slice.
func (s VolumeInfos) Less(i, j int) bool {
	iVal, _ := strconv.ParseFloat(s[i].TotalVolume, 64)
	jVal, _ := strconv.ParseFloat(s[j].TotalVolume, 64)
	return iVal > jVal
}

func (s VolumeInfos) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}
