import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/countries_service.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CountriesService _countriesService = CountriesService();
  bool _isLoading = false;

  void _searchCountry(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final country = await _countriesService.getCountryByName(query.trim());
      
      // Save search to history if successful
      if (mounted) {
        context.read<SettingsProvider>().addSearch(query.trim());
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(country: country),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Ha ocurrido un error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error de búsqueda'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Aceptar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _searchCountry(_searchController.text);
            },
            child: const Text('Reintentar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        actions: [
          // Unit toggle
          TextButton(
            onPressed: settings.toggleTemperatureUnit,
            child: Text(
              settings.temperatureUnit,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Theme toggle
          IconButton(
            icon: Icon(settings.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
            onPressed: settings.toggleTheme,
          ),
          // Favorites
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900.withOpacity(0.8), // Solid-ish dark blue
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Busca un país',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ej: Spain, Japan, Brazil...',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white54),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () => _searchCountry(_searchController.text),
                          ),
                        ),
                        onSubmitted: _searchCountry,
                      ),
                      const SizedBox(height: 16),
                      
                      // Search History Chips
                      if (settings.searchHistory.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Búsquedas recientes:', style: TextStyle(color: Colors.white70)),
                            TextButton(
                              onPressed: settings.clearHistory,
                              child: const Text('Borrar', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: settings.searchHistory.map((query) {
                            return ActionChip(
                              label: Text(query),
                              backgroundColor: Colors.white, // Solid white
                              labelStyle: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                              onPressed: () {
                                _searchController.text = query;
                                _searchCountry(query);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
