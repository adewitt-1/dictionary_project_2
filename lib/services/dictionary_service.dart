import 'dart:convert';

import '../models/dictionary_model.dart';
import 'package:http/http.dart' as http;

/// Fetches dictionary data from the API.
/// "Word" is the word to search for.
Future<List<Dictionary>> fetchDictionary(String word) async {
  word = word.trim();
  final uri = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
  final resp = await http.get(uri);

  if (resp.statusCode != 200) {
    throw Exception('Dictionary API ${resp.statusCode}');
  }

  // Raw JSON string converted to Dart object. Becomes a list of dictionaries.
  final data = jsonDecode(resp.body) as List;
  // Goes through each dictionary and converts it to a Dart object, then returns
  // as a List.
  return data.map((e) => Dictionary.fromJson(e)).toList();
}
