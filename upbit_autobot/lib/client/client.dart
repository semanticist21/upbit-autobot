import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:upbit_autobot/client/password.dart';

import '../model/log.dart';

class RestApiClient {
  RestApiClient._internal();
  static final RestApiClient _instance = RestApiClient._internal();

  factory RestApiClient() => _instance;

  final String _baseUri = 'http://localhost:8080';
  final String _baseSocketUri = 'ws://localhost:8080';
  final http.Client _client = http.Client();

  Future<http.Response?> requestPost(String pageUrl, String dataBody) async {
    var resultUrl = getUri(pageUrl);
    http.Response? response;

    try {
      response = await _client.post(resultUrl,
          headers: passwordJsonMap, body: dataBody);
    } catch (_) {
      response = null;
      return response;
    }

    return response;
  }

  Future<http.Response?> requestPostWithParamas(
      String pageUrl, String dataBody, Map<String, String> params) async {
    var resultUrl = getUri(pageUrl);
    resultUrl = resultUrl.replace(queryParameters: params);
    http.Response? response;

    try {
      response = await _client.post(resultUrl,
          headers: passwordJsonMap, body: dataBody);
    } catch (_) {
      response = null;
      return response;
    }

    return response;
  }

  Future<http.Response> requestGet(String pageUrl) async {
    var response = await _client.get(getUri(pageUrl), headers: passwordMap);

    return response;
  }

  Future<http.Response> requestGetWithParams(
      String pageUrl, Map<String, String> params) async {
    var resulturl = getUri(pageUrl);
    resulturl = resulturl.replace(queryParameters: params);

    var response = await _client.get(
      resulturl,
      headers: passwordMap,
    );

    return response;
  }

  Future<WebSocket> doConnectToWebSocket(String pageUrl) async =>
      await WebSocket.connect(getSocketUri(pageUrl).toString(),
          headers: passwordMap);

  Uri getSocketUri(String pageUrl) => Uri.parse('$_baseSocketUri/$pageUrl');

  Uri getUri(String pageUrl) => Uri.parse('$_baseUri/$pageUrl');

  static Map<String, dynamic> parseResponseData(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } else {
      doLoggerPostRequest('잘못된 응답입니다.');
      return {};
    }
  }

  static String parseWordData(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return utf8.decode(response.bodyBytes);
      } else {
        return '';
      }
    } else {
      doLoggerPostRequest('잘못된 응답입니다.');
      return '';
    }
  }

  static Future<void> doLoggerPostRequest(String msg) async {
    var log = Log();
    log.msg = msg;

    await RestApiClient().requestPost('logs', encodeData(log.toJson()));
  }

  static Future<void> doLoggerPostErrorRequest(String msg) async {
    var log = Log();
    log.errorMsg = msg;

    await RestApiClient().requestPost('logs', encodeData(log.toJson()));
  }

  static String encodeData(Map<String, dynamic> data) => json.encode(data);
}
