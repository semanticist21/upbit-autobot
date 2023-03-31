import 'dart:convert';
import 'dart:io';
import 'package:upbit_autobot/client/password.dart';

import '../model/log.dart';

class RestApiClient {
  RestApiClient._internal();
  static final RestApiClient _instance = RestApiClient._internal();

  factory RestApiClient() => _instance;

  final String _baseUri = 'http://localhost:8080';
  final String _baseSocketUri = 'ws://localhost:8080';
  final _client = HttpClient();

  void initclient() {
    _client.maxConnectionsPerHost = 100;
    _client.connectionTimeout = const Duration(seconds: 3);
  }

  Future<HttpClientResponse?> requestPost(
      String pageUrl, String dataBody) async {
    var resultUrl = getUri(pageUrl);
    HttpClientResponse? response;

    try {
      var request = await _client.postUrl(resultUrl);
      request.headers.set('content-Type', 'application/json');
      request.headers.add(passwordMap.keys.first, passwordMap.values.first);
      request.add(utf8.encode(dataBody));
      response = await request.close();
    } catch (err) {
      if (err.runtimeType == SocketException) {
        doLoggerPostRequest('연결 시간이 초과되었습니다.');
      }
    }

    return response;
  }

  Future<HttpClientResponse?> requestPostWithParamas(
      String pageUrl, String dataBody, Map<String, String> params) async {
    var resultUrl = getUri(pageUrl);
    resultUrl = resultUrl.replace(queryParameters: params);
    HttpClientResponse? response;

    try {
      var request = await _client.postUrl(resultUrl);
      request.headers.set('content-Type', 'application/json');
      request.headers.add(passwordMap.keys.first, passwordMap.values.first);
      request.add(utf8.encode(dataBody));
      response = await request.close();
    } catch (err) {
      if (err.runtimeType == SocketException) {
        doLoggerPostRequest('연결 시간이 초과되었습니다.');
      }
    }

    return response;
  }

  Future<HttpClientResponse?> requestGet(String pageUrl) async {
    HttpClientResponse? response;

    try {
      var request = await _client.getUrl(getUri(pageUrl));
      request.headers.add(passwordMap.keys.first, passwordMap.values.first);
      response = await request.close();
    } catch (err) {
      if (err.runtimeType == SocketException) {
        doLoggerPostRequest('연결 시간이 초과되었습니다.');
      }
    }

    return response;
  }

  Future<HttpClientResponse?> requestGetWithParams(
      String pageUrl, Map<String, String> params) async {
    HttpClientResponse? response;

    try {
      var resulturl = getUri(pageUrl);
      resulturl = resulturl.replace(queryParameters: params);
      var request = await _client.getUrl(getUri(pageUrl));
      request.headers.add(passwordMap.keys.first, passwordMap.values.first);
      response = await request.close();
    } catch (err) {
      if (err.runtimeType == SocketException) {
        doLoggerPostRequest('연결 시간이 초과되었습니다.');
      }
    }
    return response;
  }

  Future<WebSocket> doConnectToWebSocket(String pageUrl) async =>
      await WebSocket.connect(getSocketUri(pageUrl).toString(),
          headers: passwordMap);

  Uri getSocketUri(String pageUrl) => Uri.parse('$_baseSocketUri/$pageUrl');

  Uri getUri(String pageUrl) => Uri.parse('$_baseUri/$pageUrl');

  static Future<Map<String, dynamic>> parseResponseData(
      HttpClientResponse? response) async {
    if (response == null) {
      return Future.value({});
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseBody = await response.transform(utf8.decoder).join();

      if (responseBody.isNotEmpty) {
        return jsonDecode(responseBody);
      } else {
        return {};
      }
    } else {
      // doLoggerPostRequest('잘못된 응답입니다.');
      return {};
    }
  }

  static Future<List<dynamic>> parseResponseListData(
      HttpClientResponse? response) async {
    if (response == null) {
      return Future.value(List.empty());
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseBody = await response.transform(utf8.decoder).join();

      if (responseBody.isNotEmpty) {
        return jsonDecode(responseBody);
      } else {
        return List.empty();
      }
    } else {
      // doLoggerPostRequest('잘못된 응답입니다.');
      return List.empty();
    }
  }

  static Future<String> parseWordData(HttpClientResponse? response) async {
    if (response == null) {
      return Future.value('');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseBody = await response.transform(utf8.decoder).join();

      if (responseBody.isNotEmpty) {
        return responseBody;
      } else {
        return '';
      }
    } else {
      // doLoggerPostRequest('잘못된 응답입니다.');
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
