# WorldExplorer

Aplicacion movil desarrollada en Flutter que integra dos APIs REST publicas para ofrecer informacion completa sobre cualquier pais del mundo: datos geograficos y culturales en tiempo real combinados con la meteorologia actual de su capital.

---

## Que hace la app

Escribe el nombre de cualquier pais en ingles y la app consulta en tiempo real la informacion del pais y el clima de su capital. Las dos peticiones se encadenan automaticamente: primero se obtienen los datos del pais, y con las coordenadas de su capital se lanza la peticion meteorologica.

Funcionalidades principales:

- Busqueda de paises con historial de las ultimas 5 busquedas
- Ficha completa del pais: bandera, nombre oficial, capital, region, poblacion, idiomas, monedas, zonas horarias y paises fronterizos
- Clima actual de la capital: temperatura, viento y condicion meteorologica
- Prevision de 7 dias con iconos por tipo de tiempo
- Mapa interactivo con la ubicacion de la capital
- Sistema de favoritos persistente
- Modo oscuro y cambio de unidades entre Celsius y Fahrenheit
- Gestion de errores: sin conexion, pais no encontrado, timeout y respuesta malformada

---

## Capturas de pantalla

### Buscador

Pantalla principal con el campo de busqueda y los chips del historial de busquedas recientes. Cada chip relanza la busqueda directamente al pulsarlo.

![Buscador de paises con historial](cap3.png)

---

### Detalle del pais

Vista principal del detalle tras buscar un pais. Muestra la bandera, el nombre oficial, la capital, la region, la poblacion formateada y el clima actual de la capital con temperatura, viento e icono de condicion meteorologica.

![Detalle del pais con bandera, datos principales y clima actual](cap1.png)

---

### Informacion adicional

Parte inferior de la pantalla de detalle. Incluye el mapa interactivo centrado en la capital, la prevision meteorologica de los proximos 7 dias en formato carrusel horizontal y la seccion de informacion ampliada con idiomas, monedas, zonas horarias, fronteras y densidad de poblacion.

![Mapa, prevision de 7 dias e informacion ampliada del pais](cap2.png)

---

## Tecnologias utilizadas

- [REST Countries API](https://restcountries.com) — informacion geografica y cultural de los paises
- [Open-Meteo API](https://open-meteo.com) — meteorologia gratuita por coordenadas
- Flutter + Dart
- Paquetes: `http`, `shared_preferences`, `intl`, `provider`, `flutter_map`, `google_fonts`

---

## Instrucciones de ejecucion

```bash
flutter pub get
flutter run
```

---

## Video demostrativo

[Enlace al video]
