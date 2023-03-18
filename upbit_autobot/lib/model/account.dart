class Account {
  String publicKey;
  String secretKey;

  Account({required this.publicKey, required this.secretKey});

  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'secretKey': secretKey,
    };
  }
}
