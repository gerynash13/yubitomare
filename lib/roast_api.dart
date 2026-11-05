import 'dart:convert';
import 'package:http/http.dart' as http;

const supabaseUrl = 'https://huvqnnmcfkinlxlhatav.supabase.co';
const supabaseAnonKey = 'sb_publishable_XomYTCiO08-McfoLcPF7iQ_0ckM7Lv7';

/// Asks the intervene function for one line from Tomarin.
///
/// [level] = how many passes the user already used today (0, 1, 2...).
/// [locked] = the daily budget is gone and the card is a final "closed for today".
Future<String> fetchRoast({
  required String app,
  required int minutes,
  String? task,
  List<String>? history,
  String lang = 'en',
  String name = '',
  String suffix = 'none',
  int level = 0,
  bool locked = false,
}) async {
  final res = await http.post(
    Uri.parse('$supabaseUrl/functions/v1/intervene'),
    headers: {
      'Authorization': 'Bearer $supabaseAnonKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'app': app,
      'minutes': minutes,
      'task': task,
      'history': history ?? [],
      'lang': lang,
      'name': name,
      'suffix': suffix,
      'level': level,
      'locked': locked,
    }),
  );
  if (res.statusCode != 200) {
    throw Exception('Roast failed: ${res.statusCode} ${res.body}');
  }
  return (jsonDecode(res.body) as Map)['roast'] as String;
}