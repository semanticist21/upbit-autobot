class Log {
  String msg = '';
  String errorMsg = '';

  Log();

  Map<String, dynamic> toJson() {
    return {
      "msg": msg,
      "errorMsg": errorMsg,
    };
  }
}
