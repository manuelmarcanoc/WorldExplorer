class Weather {
  final double currentTemperature;
  final double currentWindSpeed;
  final int currentWeatherCode;
  final int isDay; // 1 = day, 0 = night
  final List<DailyForecast> dailyForecasts;

  Weather({
    required this.currentTemperature,
    required this.currentWindSpeed,
    required this.currentWeatherCode,
    required this.isDay,
    required this.dailyForecasts,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current_weather'] ?? {};
    final currentTemp = (current['temperature'] as num?)?.toDouble() ?? 0.0;
    final currentWind = (current['windspeed'] as num?)?.toDouble() ?? 0.0;
    final currentCode = (current['weathercode'] as num?)?.toInt() ?? 0;
    final isDay = (current['is_day'] as num?)?.toInt() ?? 1;

    final dailyForecasts = <DailyForecast>[];
    if (json['daily'] != null) {
      final daily = json['daily'];
      final times = daily['time'] as List<dynamic>? ?? [];
      final maxTemps = daily['temperature_2m_max'] as List<dynamic>? ?? [];
      final minTemps = daily['temperature_2m_min'] as List<dynamic>? ?? [];
      final codes = daily['weathercode'] as List<dynamic>? ?? [];

      for (int i = 0; i < times.length; i++) {
        // Prevent out of bounds
        if (i < maxTemps.length && i < minTemps.length && i < codes.length) {
          dailyForecasts.add(
            DailyForecast(
              date: times[i].toString(),
              maxTemperature: (maxTemps[i] as num).toDouble(),
              minTemperature: (minTemps[i] as num).toDouble(),
              weatherCode: (codes[i] as num).toInt(),
            ),
          );
        }
      }
    }

    return Weather(
      currentTemperature: currentTemp,
      currentWindSpeed: currentWind,
      currentWeatherCode: currentCode,
      isDay: isDay,
      dailyForecasts: dailyForecasts,
    );
  }
}

class DailyForecast {
  final String date; // e.g., "2026-05-12"
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
  });
}
