import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Marker> _marcadores = [];

  void _adicionarMarcador(LatLng ponto) {
    setState(() {
      _marcadores.add(
        Marker(
          point: ponto,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final posicaoInicial = LatLng(-23.5505, -46.6333); // São Paulo

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home com Mapa'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: posicaoInicial,
          initialZoom: 13,
          onTap: (tapPosition, point) => _adicionarMarcador(point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: _marcadores,
          ),
        ],
      ),
    );
  }
}
