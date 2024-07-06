import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class WeatherDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  WeatherDetailScreen({required this.data});

  @override
  _WeatherDetailScreenState createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  bool isLoading = false;

  String _getWeatherImage(String weatherCondition) {
    switch (weatherCondition.toLowerCase()) {
      case 'clear':
        return 'assets/cloud_img/clear_sky.png';
      case 'haze':
        return 'assets/cloud_img/haze.png';
      case 'few clouds':
        return 'assets/cloud_img/few_clouds.png';
      case 'drizzle':
        return 'assets/cloud_img/few_clouds.png';
      case 'rain':
        return 'assets/cloud_img/rain.png';
      case 'thunderstorm':
        return 'assets/cloud_img/thunder.png';
      case 'snow':
        return 'assets/cloud_img/snow.png';
      case 'broken clouds':
        return 'assets/cloud_img/cloudy.png';
      default:
        return 'assets/cloud_img/cloudy.png';
    }
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          'Weather data refreshed',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String weatherCondition = widget.data['weather'][0]['main'];
    String weatherImage = _getWeatherImage(weatherCondition);
    String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text(
          '${widget.data['name']}',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[100],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWeatherData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  weatherImage,
                  height: 300,
                  width: 500,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Description: ${widget.data['weather'][0]['description']}',
                style: const TextStyle(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildWeatherInfo(
                      'Temp',
                      isLoading
                          ? _buildShimmerLoader()
                          : '${widget.data['main']['temp']!.toString()}°C',
                    ),
                    _buildWeatherInfo(
                      'Wind',
                      isLoading
                          ? _buildShimmerLoader()
                          : '${widget.data['wind']['speed']} m/s',
                    ),
                    _buildWeatherInfo(
                      'Humidity',
                      isLoading
                          ? _buildShimmerLoader()
                          : '${widget.data['main']['humidity']}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, dynamic value) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: isLoading
          ? _buildShimmerLoader()
          : Container(
              width: 120,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 120,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
