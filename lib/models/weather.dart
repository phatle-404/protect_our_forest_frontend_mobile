import 'package:flutter/material.dart';

class WeatherState {
  final String description; // e.g. 'clear sky', 'light rain'
  final IconData icon;

  const WeatherState({required this.description, required this.icon});

  // Map các mô tả sang icon tương ứng
  static WeatherState from(String description) {
    final normalized = description.toLowerCase();

    if (normalized.contains('clear')) {
      return WeatherState(description: description, icon: Icons.wb_sunny);
    } else if (normalized.contains('cloud')) {
      return WeatherState(description: description, icon: Icons.cloud);
    } else if (normalized.contains('rain')) {
      return WeatherState(description: description, icon: Icons.umbrella);
    } else if (normalized.contains('drizzle')) {
      return WeatherState(description: description, icon: Icons.grain);
    } else if (normalized.contains('thunder')) {
      return WeatherState(description: description, icon: Icons.flash_on);
    } else if (normalized.contains('snow')) {
      return WeatherState(description: description, icon: Icons.ac_unit);
    } else if (normalized.contains('mist') ||
               normalized.contains('fog') ||
               normalized.contains('haze')) {
      return WeatherState(description: description, icon: Icons.blur_on);
    } else if (normalized.contains('tornado')) {
      return WeatherState(description: description, icon: Icons.air);
    } else {
      return WeatherState(description: description, icon: Icons.help_outline);
    }
  }
}

class WeatherDate {
  final DateTime date;
  final double temperature;
  final String description;
  final double windSpeed;
  final double humidity;
  final double rain;
  final IconData icon;

  WeatherDate({
    required this.date,
    required this.temperature,
    required this.description,
    required this.windSpeed,
    required this.humidity,
    required this.rain,
    required this.icon,
  });

  factory WeatherDate.fromJson(Map<String, dynamic> json) {
    final description = json['description'] ?? '';
    return WeatherDate(
      date: DateTime.parse(json['date']),
      temperature: (json['temperature'] as num).toDouble(),
      description: description,
      windSpeed: (json['wind'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      rain: (json['rain'] as num).toDouble(),
      icon: WeatherState.from(description).icon,
    );
  }
}

class Weather {
  final String region;
  final String country;
  final List<WeatherDate> weatherDates;

  Weather({
    required this.region,
    required this.country,
    required this.weatherDates,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      region: json['region'] ?? '',
      country: json['country'] ?? '',
      weatherDates: (json['weatherDates'] as List<dynamic>)
          .map((e) => WeatherDate.fromJson(e))
          .toList(),
    );
  }
}
