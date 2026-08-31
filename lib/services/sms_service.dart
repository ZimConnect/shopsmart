import 'dart:convert'; import 'package:http/http.dart' as http;
class SMSService { static const String _apiUrl = "https://api.smsleopard.com/v1/sms/send"; static const String _apiKey = "YOUR_SMSLEOPARD_API_KEY";
static Future<void> sendPointsNotification(String phone, String name, double points) async { String message = "Hi $name, you earned ${points.toStringAsFixed(0)} points at ShopSmart. Dial *150# to redeem. Thank you!";
  await http.post(Uri.parse(_apiUrl), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey'}, body: jsonEncode({"to": "263${phone}", "message": message, "from": "ShopSmart"})); }}
