import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

Future<Document> fetchDom(String url) async {
  final html = await http.read(url);
  return parse(html);
}

Future<Map<String, dynamic>> getJson(String url) async {
  final json = await http.read(url);
  return jsonDecode(json);
}
