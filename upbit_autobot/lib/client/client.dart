import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RestApiClient {
  RestApiClient._internal();
  static final RestApiClient _instance = RestApiClient._internal();

  factory RestApiClient() => _instance;

  final String _baseUri = 'http://localhost:8080';
  final http.Client _client = http.Client();

  Future<http.Response?> requestPost(String pageUrl, String dataBody) async {
    var resultUrl = getUri(pageUrl);
    http.Response? response;

    try {
      response = await _client.post(resultUrl,
          headers: {'Content-Type': 'application/json'}, body: dataBody);
    } catch (_) {
      response = null;
      return response;
    }

    return response;
  }

  Future<http.Response> requestGet(String pageUrl) async {
    var response = await _client.get(getUri(pageUrl));

    return response;
  }

  Uri getUri(String pageUrl) => Uri.parse('$_baseUri/$pageUrl');
}

String encodeData(Map<String, dynamic> data) => json.encode(data);

Map<String, dynamic> parseResponseData(http.Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    if (response.body.isNotEmpty) {
      return jsonDecode(response.body);
    } else {
      return {};
    }
  } else {
    return {};
  }
}

String parseWordData(http.Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    if (response.body.isNotEmpty) {
      return utf8.decode(response.bodyBytes);
    } else {
      return '';
    }
  } else {
    return '';
  }
}
