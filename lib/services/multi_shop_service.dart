import 'package:supabase_flutter/supabase_flutter.dart';
class MultiShopService { static final supabase = Supabase.instance.client;
static Future<List> getAllShops() async { final res = await supabase.from('shops').select(); return res; }
static Future<double> getShopRevenue(String shopId) async { final res = await supabase.from('sales').select('total').eq('shop_id', shopId); return res.fold(0.0, (sum, item) => sum + (item['total'] as double)); }}
