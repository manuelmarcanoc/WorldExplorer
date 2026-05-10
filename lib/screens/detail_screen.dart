import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/country.dart';
import '../models/weather.dart';
import '../providers/settings_provider.dart';
import '../services/weather_service.dart';
import '../services/countries_service.dart'; // Per l'ApiException

class DetailScreen extends StatefulWidget {
  final Country country;

  const DetailScreen({super.key, required this.country});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  bool _isLoadingWeather = true;
  String? _weatherError;
  bool _showMoreInfo = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      final weather = await _weatherService.getWeather(
        widget.country.latitude,
        widget.country.longitude,
      );
      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoadingWeather = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _weatherError = e.message;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherError = 'Error inesperado al cargar el clima: $e';
          _isLoadingWeather = false;
        });
      }
    }
  }

  IconData _getWeatherIcon(int code) {
    // Basic mapping of WMO Weather interpretation codes
    if (code == 0) return Icons.wb_sunny; // Clear sky
    if (code == 1 || code == 2 || code == 3) return Icons.cloud; // Partly cloudy
    if (code == 45 || code == 48) return Icons.foggy; // Fog
    if (code >= 51 && code <= 67) return Icons.water_drop; // Rain/Drizzle
    if (code >= 71 && code <= 82) return Icons.ac_unit; // Snow
    if (code >= 95 && code <= 99) return Icons.thunderstorm; // Thunderstorm
    return Icons.cloud; // Default
  }

  String _getWeatherDescription(int code) {
    if (code == 0) return 'Cielo despejado';
    if (code == 1 || code == 2 || code == 3) return 'Nuboso';
    if (code == 45 || code == 48) return 'Niebla';
    if (code >= 51 && code <= 67) return 'Lluvia';
    if (code >= 71 && code <= 82) return 'Nieve';
    if (code >= 95 && code <= 99) return 'Tormenta';
    return 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isFavorite = settings.isFavorite(widget.country.commonName);
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.country.commonName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? Colors.red : Colors.white,
            onPressed: () => settings.toggleFavorite(widget.country.commonName),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(settings.isDarkMode ? 'oscuro.png' : 'fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bandera i Info Bàsica
                Card(
                  color: settings.isDarkMode ? const Color(0xFF1A237E) : Colors.white,
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.country.flagUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  widget.country.flagUrl,
                                  width: 60,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.country.commonName,
                                style: GoogleFonts.caveat(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                  color: settings.isDarkMode ? Colors.white : Colors.indigo.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text(
                          widget.country.officialName, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: settings.isDarkMode ? Colors.white70 : Colors.black87,
                          )
                        ),
                        subtitle: Text(
                          '${widget.country.region} · ${widget.country.subregion}',
                          style: TextStyle(color: settings.isDarkMode ? Colors.white54 : Colors.black54),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_city, color: Colors.indigo),
                        title: Text('Capital', style: TextStyle(color: settings.isDarkMode ? Colors.white : Colors.black87)),
                        trailing: Text(
                          widget.country.capital, 
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: settings.isDarkMode ? Colors.white : Colors.black87,
                          )
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people, color: Colors.indigo),
                        title: Text('Población', style: TextStyle(color: settings.isDarkMode ? Colors.white : Colors.black87)),
                        trailing: Text(
                          numberFormat.format(widget.country.population), 
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: settings.isDarkMode ? Colors.white : Colors.black87,
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Mapa (Nuevo!)
                const Text('Ubicación en el Mapa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                _buildMinimap(),
                
                const SizedBox(height: 16),

                // Meteorologia Actual
                Text('Clima en la Capital', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: settings.isDarkMode ? Colors.white : Colors.white)),
                const SizedBox(height: 8),
                _buildCurrentWeather(settings),
                
                const SizedBox(height: 16),

                // Previsió de 7 dies (E2)
                if (_weather != null && _weather!.dailyForecasts.isNotEmpty) ...[
                  Text('Previsión a 7 días', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: settings.isDarkMode ? Colors.white : Colors.white)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _weather!.dailyForecasts.length,
                      itemBuilder: (context, index) {
                        final forecast = _weather!.dailyForecasts[index];
                        final maxTemp = settings.convertTemperature(forecast.maxTemperature);
                        final minTemp = settings.convertTemperature(forecast.minTemperature);
                        
                        return Card(
                          color: settings.isDarkMode ? const Color(0xFF1A237E) : Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  forecast.date.substring(5), 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: settings.isDarkMode ? Colors.white70 : Colors.indigo
                                  )
                                ),
                                Icon(_getWeatherIcon(forecast.weatherCode), color: settings.isDarkMode ? Colors.white : Colors.indigo),
                                Text(
                                  '${maxTemp.toStringAsFixed(1)}° / ${minTemp.toStringAsFixed(1)}°',
                                  style: TextStyle(color: settings.isDarkMode ? Colors.white : Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Més informació (E3)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showMoreInfo = !_showMoreInfo;
                    });
                  },
                  child: Text(_showMoreInfo ? 'Ocultar información' : 'Más información'),
                ),
                if (_showMoreInfo) _buildMoreInfo(settings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimap() {
    final latLng = LatLng(widget.country.latitude, widget.country.longitude);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 4,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: latLng,
                initialZoom: 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.world_explorer',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latLng,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Ver en Google Maps', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Abrir ubicación exacta'),
            trailing: const Icon(Icons.open_in_new, color: Colors.indigo),
            onTap: () async {
              final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${widget.country.latitude},${widget.country.longitude}');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(SettingsProvider settings) {
    if (_isLoadingWeather) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_weatherError != null) {
      return Card(
        color: Colors.red.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_weatherError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadWeather,
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      );
    }

    if (_weather == null) return const SizedBox();

    final currentTemp = settings.convertTemperature(_weather!.currentTemperature);

    return Card(
      color: settings.isDarkMode ? const Color(0xFF1A237E) : Colors.white,
      child: ListTile(
        leading: Icon(_getWeatherIcon(_weather!.currentWeatherCode), size: 40, color: settings.isDarkMode ? Colors.white : Colors.indigo),
        title: Text(
          '${currentTemp.toStringAsFixed(1)}${settings.temperatureUnit} - ${_getWeatherDescription(_weather!.currentWeatherCode)}',
          style: TextStyle(fontSize: 20, color: settings.isDarkMode ? Colors.white : Colors.black87),
        ),
        subtitle: Text('Viento: ${_weather!.currentWindSpeed} km/h', style: TextStyle(color: settings.isDarkMode ? Colors.white54 : Colors.black54)),
      ),
    );
  }

  Widget _buildMoreInfo(SettingsProvider settings) {
    double density = 0.0;
    if (widget.country.area > 0) {
      density = widget.country.population / widget.country.area;
    }

    return Card(
      color: settings.isDarkMode ? const Color(0xFF1A237E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Idiomas:', widget.country.languages.join(', '), settings),
            const Divider(),
            _infoRow('Monedas:', widget.country.currencies.join(', '), settings),
            const Divider(),
            _infoRow('Zonas horarias:', widget.country.timezones.join(', '), settings),
            const Divider(),
            _infoRow('Fronteras:', widget.country.borders.isEmpty ? 'Ninguna' : widget.country.borders.join(', '), settings),
            const Divider(),
            _infoRow('Densidad de población:', '${density.toStringAsFixed(2)} hab/km²', settings),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: settings.isDarkMode ? Colors.white70 : Colors.black)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: settings.isDarkMode ? Colors.white : Colors.black87))),
        ],
      ),
    );
  }
}
