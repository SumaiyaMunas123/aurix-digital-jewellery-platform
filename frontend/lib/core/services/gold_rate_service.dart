import 'package:dio/dio.dart';
import '../config/environment.dart';

class GoldRateService {
  static String get _goldUrl => '${Environment.goldRateUrl}/gold-rate';

  static Future<Map<String, dynamic>> getAllRates() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        _goldUrl,
        options: Options(receiveTimeout: const Duration(seconds: 15)),
      );

      if (response.statusCode == 200) {
        return response.data ?? {};
      }
      return {};
    } catch (e) {
      print('Error fetching gold rates: $e');
      return {};
    }
  }

  static Future<double?> getGoldRate() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$_goldUrl/gold',
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('gold') && data['gold'] != null) {
          return double.tryParse(data['gold']['xauUsd'].toString());
        }
      }
      return null;
    } catch (e) {
      print('Error fetching gold rate: $e');
      return null;
    }
  }

  static Future<double?> getSilverRate() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$_goldUrl/silver',
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('silver') && data['silver'] != null) {
          return double.tryParse(data['silver']['xagUsd'].toString());
        }
      }
      return null;
    } catch (e) {
      print('Error fetching silver rate: $e');
      return null;
    }
  }

  static Future<double?> getPlatinumRate() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$_goldUrl/platinum',
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('platinum') && data['platinum'] != null) {
          return double.tryParse(data['platinum']['xptUsd'].toString());
        }
      }
      return null;
    } catch (e) {
      print('Error fetching platinum rate: $e');
      return null;
    }
  }
}
