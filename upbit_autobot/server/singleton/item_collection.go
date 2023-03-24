package singleton

import "github.com/semanticist21/upbit-client-server/model"

var itemsCh chan *model.ItemCollectionForSocket

func InitItemsCh() {
	itemsCh = make(chan *model.ItemCollectionForSocket)
}

func InstanceItemsCollectionCh() chan *model.ItemCollectionForSocket {
	return itemsCh
}
