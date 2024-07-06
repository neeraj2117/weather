import 'package:flutter/material.dart';
import 'package:weather/screens/weather_detail.dart';
import 'package:weather/services/weather.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  List<String> cities = ['Mumbai'];
  Map<String, dynamic> weatherData = {};
  List<String> searchHistory = [];

  final WeatherService weatherService = WeatherService();

  final TextEditingController _searchController = TextEditingController();

  String backgroundImage = 'assets/images/drizzle.jpg';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchWeatherData() async {
    for (String city in cities) {
      try {
        var data = await weatherService.fetchWeatherData(city);
        setState(() {
          weatherData[city] = data;
          updateBackgroundImage(data['weather'][0]['main']);
        });
      } catch (e) {
        print('Failed to fetch weather data for $city: $e');
      }
    }
  }

  Future<void> searchWeather(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      var data = await weatherService.fetchWeatherData(query);
      setState(() {
        cities = [query];
        weatherData[query] = data;
        updateBackgroundImage(data['weather'][0]['main']);
        updateSearchHistory(query);
        isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch weather data for $query: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateBackgroundImage(String weatherCondition) {
    setState(() {
      switch (weatherCondition.toLowerCase()) {
        case 'rain':
          backgroundImage = 'assets/images/rainy.jpg';
          break;
        case 'drizzle':
          backgroundImage = 'assets/images/drizzle.jpg';
          break;
        case 'thunderstorm':
          backgroundImage = 'assets/images/thunder.jpg';
          break;
        case 'clear':
          backgroundImage = 'assets/images/sunny.jpg';
          break;
        case 'clouds':
          backgroundImage = 'assets/images/cloudy.jpg';
          break;
        case 'snow':
          backgroundImage = 'assets/images/snow.jpg';
          break;
        default:
          backgroundImage = 'assets/images/drizzle.jpg';
          break;
      }
    });
  }

  void navigateToWeatherDetail(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherDetailScreen(data: data),
      ),
    );
  }

  Future<void> loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> updateSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!searchHistory.contains(query)) {
        if (searchHistory.length > 10) {
          searchHistory.removeAt(0);
        }
        searchHistory.add(query);
        prefs.setStringList('searchHistory', searchHistory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.25),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          cursorColor: Colors.white,
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Enter city name",
                            hintStyle: TextStyle(
                              fontSize: 23,
                              color: Colors.grey[300],
                              fontWeight: FontWeight.normal,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(1),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              searchWeather(value);
                              _searchController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 63,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: Colors.white),
                        ),
                        child: IconButton(
                          icon: isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.search,
                                  size: 32,
                                  color: Colors.white,
                                ),
                          onPressed: () {
                            if (!isLoading &&
                                _searchController.text.isNotEmpty) {
                              searchWeather(_searchController.text);
                              _searchController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                if (searchHistory.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                children: searchHistory.map((place) {
                                  return Chip(
                                    label: Text(
                                      place,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white),
                                    onDeleted: () {
                                      setState(() {
                                        searchHistory.remove(place);
                                      });
                                      SharedPreferences.getInstance()
                                          .then((prefs) {
                                        prefs.setStringList(
                                            'searchHistory', searchHistory);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 15),
                if (weatherData.isEmpty || cities.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (cities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: GestureDetector(
                      onTap: () {
                        navigateToWeatherDetail(weatherData[cities.last]);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cities.last.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (weatherData[cities.last] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${weatherData[cities.last]['main']['temp']}°',
                                        style: const TextStyle(
                                          fontSize: 110,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 250),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (weatherData.isEmpty || cities.isEmpty)
                        CircularProgressIndicator()
                      else if (weatherData[cities.last] != null &&
                          weatherData[cities.last]['weather'] != null &&
                          weatherData[cities.last]['weather'].isNotEmpty)
                        Text(
                          _getDescriptionText(
                              weatherData[cities.last]['weather'][0]['main']),
                          style: const TextStyle(
                            fontSize: 21,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: Colors.white, width: .5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${weatherData[cities.last]['main']['humidity']}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Humidity',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 60,
                          width: .5,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${weatherData[cities.last]['wind']['speed']} m/s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Wind Speed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 60,
                          width: .5,
                          color: Colors.white,
                        ),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'N/A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Air Quality',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDescriptionText(String weatherCondition) {
    switch (weatherCondition.toLowerCase()) {
      case 'rain':
        return 'It\'s raining';
      case 'drizzle':
        return 'Drizzle expected';
      case 'thunderstorm':
        return 'Thunderstorms approaching';
      case 'clear':
        return 'Clear skies';
      case 'clouds':
        return 'Cloudy weather';
      case 'snow':
        return 'Snowfall expected';
      default:
        return 'Weather update';
    }
  }
}
