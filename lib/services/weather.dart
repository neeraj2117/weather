import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'd375a4a6bf505dded5fc573a06e17e16';

  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    final Uri uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var airQualityResponse =
          await fetchAirQualityData(data['coord']['lat'], data['coord']['lon']);
      data['air_quality'] = airQualityResponse;
      return data;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> fetchAirQualityData(
      double lat, double lon) async {
    final Uri uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load air quality data');
    }
  }
}
