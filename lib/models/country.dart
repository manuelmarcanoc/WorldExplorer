class Country {
  final String commonName;
  final String officialName;
  final String flagUrl;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final double latitude;
  final double longitude;
  final List<String> languages;
  final List<String> currencies;
  final List<String> timezones;
  final List<String> borders;
  final double area;

  Country({
    required this.commonName,
    required this.officialName,
    required this.flagUrl,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.latitude,
    required this.longitude,
    required this.languages,
    required this.currencies,
    required this.timezones,
    required this.borders,
    required this.area,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Name
    final nameJson = json['name'] ?? {};
    final commonName = nameJson['common'] ?? 'Unknown';
    final officialName = nameJson['official'] ?? 'Unknown';

    // Flag
    final flagsJson = json['flags'] ?? {};
    final flagUrl = flagsJson['png'] ?? '';

    // Capital
    final capitalList = json['capital'] as List<dynamic>?;
    final capital = (capitalList != null && capitalList.isNotEmpty) ? capitalList.first.toString() : 'No capital';

    // LatLng (prefer capitalInfo, fallback to general latlng)
    double lat = 0.0;
    double lng = 0.0;
    final capitalInfo = json['capitalInfo'] ?? {};
    final capitalLatLng = capitalInfo['latlng'] as List<dynamic>?;
    if (capitalLatLng != null && capitalLatLng.length >= 2) {
      lat = (capitalLatLng[0] as num).toDouble();
      lng = (capitalLatLng[1] as num).toDouble();
    } else {
      final countryLatLng = json['latlng'] as List<dynamic>?;
      if (countryLatLng != null && countryLatLng.length >= 2) {
        lat = (countryLatLng[0] as num).toDouble();
        lng = (countryLatLng[1] as num).toDouble();
      }
    }

    // Languages
    final languagesList = <String>[];
    if (json['languages'] != null) {
      final langsMap = json['languages'] as Map<String, dynamic>;
      languagesList.addAll(langsMap.values.map((e) => e.toString()));
    }

    // Currencies
    final currenciesList = <String>[];
    if (json['currencies'] != null) {
      final currMap = json['currencies'] as Map<String, dynamic>;
      currMap.forEach((key, value) {
        final name = value['name'] ?? '';
        final symbol = value['symbol'] ?? '';
        currenciesList.add('$name ($symbol)');
      });
    }

    // Timezones
    final timezonesList = <String>[];
    if (json['timezones'] != null) {
      timezonesList.addAll((json['timezones'] as List<dynamic>).map((e) => e.toString()));
    }

    // Borders
    final bordersList = <String>[];
    if (json['borders'] != null) {
      bordersList.addAll((json['borders'] as List<dynamic>).map((e) => e.toString()));
    }

    return Country(
      commonName: commonName,
      officialName: officialName,
      flagUrl: flagUrl,
      capital: capital,
      region: json['region'] ?? 'Unknown',
      subregion: json['subregion'] ?? 'Unknown',
      population: json['population'] ?? 0,
      latitude: lat,
      longitude: lng,
      languages: languagesList,
      currencies: currenciesList,
      timezones: timezonesList,
      borders: bordersList,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
