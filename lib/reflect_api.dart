import 'dart:convert';
import 'package:http/http.dart' as http;
import 'roast_api.dart' show supabaseUrl, supabaseAnonKey;

/// Asks the `reflect` function for Tomarin's red-pen comment.
///
/// [progress] is none, little, fair or great. [note] is what the user wrote (may be empty).
/// Returns null when the function has no usable line; the caller then keeps the fixed line.
Future<String?> fetchReflection({
  required String lang,
  required String name,
  required String suffix,
  required String progress,
  required String note,
  required String goal,
  required int minutes,
}) async {
  final res = await http.post(
    Uri.parse('$supabaseUrl/functions/v1/reflect'),
    headers: {
      'Authorization': 'Bearer $supabaseAnonKey',
      'Content-Type': 'application/json; charset=utf-8',
    },
    body: jsonEncode({
      'lang': lang,
      'name': name,
      'suffix': suffix,
      'progress': progress,
      'note': note,
      'goal': goal,
      'minutes': minutes,
    }),
  );
  if (res.statusCode != 200) {
    throw Exception('Reflect failed: ${res.statusCode}');
  }
  final reply = (jsonDecode(utf8.decode(res.bodyBytes)) as Map)['reply'];
  return reply is String && reply.trim().isNotEmpty ? reply.trim() : null;
}