import 'dart:convert'; import 'package:http/http.dart' as http;
class EcoCashService { static const String _apiUrl = "https://api.ecocash.co.zw/merchant/v2/payments"; static const String _merchantCode = "YOUR_ECOCASH_MERCHANT_CODE"; static const String _apiKey = "YOUR_ECOCASH_API_KEY";
static Future<Map<String, dynamic>> requestPayment(String phone, double amount, String reference) async {
  final response = await http.post(Uri.parse(_apiUrl), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey'}, body: jsonEncode({"merchantCode": _merchantCode, "amount": amount, "phoneNumber": "263${phone}", "reference": reference}));
  if(response.statusCode == 200) return jsonDecode(response.body); else throw Exception("EcoCash Payment Failed"); }}
