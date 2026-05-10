import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/countries_service.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final CountriesService _countriesService = CountriesService();
  bool _isLoading = false;

  void _openFavorite(String countryName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final country = await _countriesService.getCountryByName(countryName);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(country: country),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el país: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final favorites = settings.favorites;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Países Favoritos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
          child: Stack(
            children: [
              if (favorites.isEmpty)
                const Center(child: Text('Aún no tienes países favoritos.', style: TextStyle(color: Colors.white)))
              else
                ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final countryName = favorites[index];
                    return Card(
                      color: settings.isDarkMode ? const Color(0xFF1A237E) : Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.public, color: Colors.indigo),
                        title: Text(
                          countryName, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: settings.isDarkMode ? Colors.white : Colors.indigo
                          )
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => settings.toggleFavorite(countryName),
                        ),
                        onTap: () => _openFavorite(countryName),
                      ),
                    );
                  },
                ),
              
              if (_isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
