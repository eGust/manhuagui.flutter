import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

Future<Document> fetchDom(String url, {Map<String, String> headers}) async {
  final html = await http.read(Uri.parse(url), headers: headers);
  return parse(html);
}

Future<Document> fetchAjaxDom(String url, {Map<String, String> headers}) async {
  final html = await http.read(Uri.parse(url), headers: headers);
  return parse('<html>$html</html>');
}

Future<Map<String, dynamic>> getJson(String url,
    {Map<String, String> headers}) async {
  final json = await http.read(Uri.parse(url), headers: headers);
  return jsonDecode(json);
}

Future<Map<String, Map<String, dynamic>>> postJsonRaw(String url,
    {Map<String, String> body, Map<String, String> headers}) async {
  final response = await http.post(Uri.parse(url), headers: headers, body: body);
  return {
    'headers': response.headers,
    'body': jsonDecode(response.body),
  };
}

Future<Map<String, dynamic>> postJson(String url,
    {Map<String, String> body, Map<String, String> headers}) async {
  final response = await http.post(Uri.parse(url), headers: headers, body: body);
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> postJsonQuery(String url, String json) async {
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json,
  );
  final data = utf8.decode(response.bodyBytes);
  return jsonDecode(data);
}

const _SEARCH_BASE_URL = 'https://www.manhuagui.com/tools/word.ashx';

Future<List<Map<String, dynamic>>> searchPreview(final String key) async {
  final url = '$_SEARCH_BASE_URL?key=${Uri.encodeQueryComponent(key)}';
  final json = await http.read(Uri.parse(url));
  return List<Map<String, dynamic>>.from(jsonDecode(json));
}
