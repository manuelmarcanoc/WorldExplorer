# WorldExplorer

Aplicacion movil desarrollada en Flutter que permite a los usuarios consultar informacion cultural y geografica de cualquier pais del mundo junto con la meteorologia actual y la prevision de 7 dias de su capital.

Practica PR-RA3-04 — Modulo 0489 Programacion Multimedia y Dispositivos Moviles — 2n DAM 2025-26

---

## Fase 1: Investigacion de las APIs

**1. Que endpoint de REST Countries se usa para buscar un pais por nombre? Que campos devuelve relevantes para la app?**

Se usa el endpoint `https://restcountries.com/v3.1/name/{nombre}?fullText=false`.
Los campos relevantes que se utilizan son: `name.common`, `name.official`, `flags.png`, `capital`, `region`, `subregion`, `population`, `capitalInfo.latlng`, `languages`, `currencies`, `timezones`, `borders`, `area`.

**2. Como se obtienen las coordenadas (latitud, longitud) de un pais en REST Countries?**

Se obtienen del campo `capitalInfo.latlng`, que contiene las coordenadas de la capital. Si ese campo no existe (algunos territorios sin capital reconocida), se usa como fallback el campo general `latlng` del pais.

**3. Que endpoint de Open-Meteo se usa para la meteorologia actual? Que query parameters acepta?**

Se usa el endpoint `https://api.open-meteo.com/v1/forecast`.
Los parametros que se envian son:
- `latitude` y `longitude` — coordenadas de la capital.
- `current_weather=true` — para obtener el clima actual.
- `daily=temperature_2m_max,temperature_2m_min,weathercode` — para la prevision de 7 dias.
- `timezone=auto` — para ajustar la prevision a la zona horaria local.

**4. Que formato tiene la respuesta JSON de Open-Meteo?**

La respuesta es un objeto JSON con la siguiente estructura:
- `current_weather`: objeto con `temperature`, `windspeed`, `weathercode`, `is_day` y `time`.
- `daily`: objeto con arrays indexados por dia, que incluye `time`, `temperature_2m_max`, `temperature_2m_min` y `weathercode`.
- Metadatos adicionales como `latitude`, `longitude`, `elevation` y `timezone`.

---

## Funcionalidades implementadas

### Diseno base (4 puntos)

- B1: Buscador de paises con peticion a REST Countries, indicador de carga y manejo de errores.
- B2: Pantalla de detalle con bandera, nombre oficial y comun, capital, region, subregion y poblacion formateada.
- B3: Meteorologia actual de la capital integrada mediante peticiones asincronas encadenadas.

### Extensiones opcionales (8 puntos)

- E1: Sistema de favoritos persistente con shared_preferences. Se pueden anadir, eliminar y ver desde una pantalla dedicada.
- E2: Prevision meteorologica de 7 dias con iconos mapeados a los weathercodes de Open-Meteo.
- E3: Vista detallada del pais: idiomas oficiales, monedas con simbolo, zonas horarias, paises fronterizos y densidad de poblacion calculada.
- E4: Historial de las ultimas 5 busquedas, persistente, con chips clicables y boton para borrar.
- E5: Toggle modo oscuro/claro y selector de unidades de temperatura grados C / grados F. Ambas preferencias persisten entre sesiones.
- E6: Gestion robusta de los 4 casos de error: sin conexion a Internet (SocketException), pais no encontrado (404), timeout (mas de 10 segundos) y respuesta malformada (FormatException). Todos muestran un mensaje claro al usuario y un boton de reintentar.

---

## Capturas de pantalla

![Pantalla principal de busqueda con historial de busquedas recientes](cap1.png)

---

## Instrucciones de ejecucion

Requisitos previos: Flutter SDK instalado y un dispositivo Android conectado o emulador activo.

```bash
flutter pub get
flutter run
```

Para compilar el APK:

```bash
flutter build apk --release
```

---

## Video demostrativo

[Enlace al video en YouTube o Google Drive]

---

## Dependencias utilizadas

| Paquete | Version | Uso |
|---------|---------|-----|
| http | ^1.6.0 | Peticiones GET a las dos APIs REST. Obligatorio segun el enunciado. |
| shared_preferences | ^2.5.5 | Persistencia de favoritos, historial y preferencias de usuario entre sesiones. |
| intl | ^0.20.2 | Formateo de la poblacion con separadores de miles. |
| provider | ^6.1.5+1 | Gestion del estado global de la app (tema, favoritos, historial, unidades). |
| flutter_map | ^8.3.0 | Mapa interactivo con OpenStreetMap en la pantalla de detalle del pais. |
| latlong2 | ^0.9.1 | Tipos de coordenadas geograficas requeridos por flutter_map. |
| url_launcher | ^6.3.2 | Apertura de Google Maps desde el minimapa del detalle. |
| google_fonts | ^8.1.0 | Tipografia Caveat para el nombre del pais en la pantalla de detalle. |

---

## Uso de inteligencia artificial

Se han utilizado herramientas de inteligencia artificial como ayuda en el desarrollo, siguiendo las politicas de integridad academica del centro. Todo el codigo entregado ha sido revisado y comprendido en su totalidad.

---

## Autor

Manuel — 2n DAM 2025-26 — PR-RA3-04
