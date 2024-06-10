import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}


class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SubcategoryScreen()),
            );
          },
          child: Text('Select Location'),
        ),
      ),
    );
  }
}

class SubcategoryScreen extends StatelessWidget {
  const SubcategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Subcategory'),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchWeatherCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeatherDetailsScreen(location: snapshot.data![index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class WeatherDetailsScreen extends StatelessWidget {
  final String location;

  const WeatherDetailsScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchWeatherDetails(location),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var weatherData = snapshot.data!;
            var forecastDays = weatherData['forecast']['forecastday'];
            return ListView.builder(
              itemCount: forecastDays.length,
              itemBuilder: (context, index) {
                var day = forecastDays[index];
                return Card(
                  child: ListTile(
                    title: Text('Date: ${day['date']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Temperature: ${day['day']['avgtemp_c']} °C'),
                        Text('Condition: ${day['day']['condition']['text']}'),
                        Text('Humidity: ${day['day']['avghumidity']} %'),
                        Text('Wind Speed: ${day['day']['maxwind_kph']} kph'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchWeatherDetails(String location) async {
    final response = await http.get(Uri.parse('https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$location&days=3'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather details');
    }
  }
}

const apiKey = '2369675f61bc42fe83e115355240306';

Future<List<String>> fetchWeatherCategories() async {
  List<String> locations = ['Istanbul', 'Ankara', 'Izmir'];
  List<String> categories = [];

  for (var location in locations) {
    final response = await http.get(Uri.parse('https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$location&days=3'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      categories.add('${data['location']['name']}, ${data['location']['region']}, ${data['location']['country']}');
    } else {
      throw Exception('Failed to load categories');
    }
  }

  return categories;
}
