package model

type KeyStore struct {
	PublicKey  string
	PrivateKey string
}

func NewKeyStore(privateKey string, publicKey string) *KeyStore {
	return &KeyStore{
		publicKey,
		privateKey,
	}
}
