import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/alert/AlertManager.dart';
import '../../services/AlertService.dart';
import '../../components/alert/AlertMarker.dart';
import '../../components/alert/AlertDetailsDialog.dart';
import '../../components/alert/CreateAlertDialog.dart';

class MapScreen extends StatefulWidget {
  final String userId;
  final AlertService alertService;

  const MapScreen({Key? key, required this.userId, required this.alertService})
      : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Marker> _marcadores = [];
  final LatLng _posicaoInicial = LatLng(-21.202248, -41.903281);
  late AlertManager _alertManager;

  @override
  void initState() {
    super.initState();
    _alertManager = AlertManager(
      alertService: widget.alertService,
      userId: widget.userId,
    );
    _carregarAlertas();
  }

  Future<void> _carregarAlertas() async {
    try {
      final resultado = await _alertManager.getAllAlerts();

      if (resultado['status'] == 200 && resultado['data'] != null) {
        final alertas = resultado['data'] as List<Map<String, dynamic>>;

        setState(() {
          _marcadores.clear();

          for (var alerta in alertas) {
            final lat = alerta['latitude'] as double;
            final lng = alerta['longitude'] as double;

            _marcadores.add(
              AlertMarker(
                point: LatLng(lat, lng),
                onTap: () => _mostrarDetalhesAlerta(alerta),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar alertas: $e')));
      }
    }
  }

  void _mostrarDetalhesAlerta(Map<String, dynamic> alerta) {
    final String alertaId = alerta['id'];
    final String? userVoteType = _alertManager.userVotes[alertaId];

    showDialog(
      context: context,
      builder: (context) => AlertDetailsDialog(
        alerta: alerta,
        userVoteType: userVoteType,
        onUpvote: _darUpvote,
        onDownvote: _darDownvote,
      ),
    );
  }

  Future<void> _darUpvote(
    Map<String, dynamic> alerta,
    StateSetter dialogSetState,
  ) async {
    try {
      final alertaId = alerta['id'];
      final resultado = await _alertManager.vote(alertaId, true);

      if (resultado['status'] == 200) {
        if (resultado['data'] != null) {
          dialogSetState(() {
            alerta['ups'] = resultado['data']['ups'];
            alerta['downs'] = resultado['data']['downs'];
          });

          _atualizarMarcador(alertaId, alerta);

          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Voto registrado!')));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resultado['message']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao registrar voto: $e')));
    }
  }

  Future<void> _darDownvote(
    Map<String, dynamic> alerta,
    StateSetter dialogSetState,
  ) async {
    try {
      final alertaId = alerta['id'];
      final resultado = await _alertManager.vote(alertaId, false);

      if (resultado['status'] == 200) {
        if (resultado['data'] != null) {
          dialogSetState(() {
            alerta['ups'] = resultado['data']['ups'];
            alerta['downs'] = resultado['data']['downs'];
          });

          _atualizarMarcador(alertaId, alerta);

          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Voto registrado!')));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resultado['message']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao registrar voto: $e')));
    }
  }

  void _atualizarMarcador(
    String alertaId,
    Map<String, dynamic> alertaAtualizado,
  ) {
    final index = _marcadores.indexWhere((marker) {
      if (marker.child is GestureDetector) {
        final gestureDetector = marker.child as GestureDetector;
        if (gestureDetector.onTap != null) {
          return true;
        }
      }
      return false;
    });

    if (index >= 0) {
      final lat = alertaAtualizado['latitude'] as double;
      final lng = alertaAtualizado['longitude'] as double;

      setState(() {
        _marcadores[index] = AlertMarker(
          point: LatLng(lat, lng),
          onTap: () => _mostrarDetalhesAlerta(alertaAtualizado),
        );
      });
    }
  }

  void _handleMapTap(LatLng point) {
    _abrirModalCriarAlerta(point);
  }

  void _abrirModalCriarAlerta(LatLng ponto) {
    showDialog(
      context: context,
      builder: (context) =>
          CreateAlertDialog(point: ponto, onCreateAlert: _criarAlerta),
    );
  }

  Future<void> _criarAlerta(
      LatLng ponto, String? descricao, File? imageFile) async {
    String? imageUrl;
    if (imageFile != null) {
      try {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
        await Supabase.instance.client.storage
            .from('alert')
            .upload(fileName, imageFile);
        imageUrl = Supabase.instance.client.storage
            .from('alert')
            .getPublicUrl(fileName);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
          );
        }
        return; // Não continue se o upload falhar
      }
    }

    try {
      final resultado = await _alertManager.createAlert(
        coordinates: ponto,
        description: descricao,
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      if (resultado['status'] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta criado com sucesso!')),
        );
        await _carregarAlertas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resultado['message']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao criar alerta: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _alertManager,
      builder: (context, child) {
        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _posicaoInicial,
                initialZoom: 15,
                onTap: (tapPosition, point) => _handleMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: _marcadores),
              ],
            ),
            if (_alertManager.isLoading)
              Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
