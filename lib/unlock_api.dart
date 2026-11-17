import 'dart:convert';
import 'package:http/http.dart' as http;
import 'roast_api.dart' show supabaseUrl, supabaseAnonKey;

/// Asks the `unblock` function for one tiny first step for [task].
///
/// [hard] is what feels hard: big, start, afraid or boring.
/// Returns null when the function has no usable line; the caller then keeps the fixed line.
Future<String?> fetchUnblock({
  required String lang,
  required String name,
  required String suffix,
  required String task,
  required String hard,
}) async {
  final res = await http.post(
    Uri.parse('$supabaseUrl/functions/v1/unblock'),
    headers: {
      'Authorization': 'Bearer $supabaseAnonKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'lang': lang,
      'name': name,
      'suffix': suffix,
      'task': task,
      'hard': hard,
    }),
  );
  if (res.statusCode != 200) {
    throw Exception('Unblock failed: ${res.statusCode}');
  }
  final reply = (jsonDecode(utf8.decode(res.bodyBytes)) as Map)['reply'];
  return reply is String && reply.trim().isNotEmpty ? reply.trim() : null;
}