import 'package:buraco/components/CustomAppBar.dart';
import 'package:buraco/components/CustomBottomNav.dart';
import 'package:buraco/screens/Login.dart';
import 'package:buraco/services/UserPreferencesService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:developer' as developer;
import '../services/AlertService.dart';
import '../components/AlertMarker.dart';
import '../components/AlertDetailsDialog.dart';
import '../components/CreateAlertDialog.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Marker> _marcadores = [];
  final AlertService _alertService = AlertService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final LatLng _posicaoInicial = LatLng(-21.202248, -41.903281);
  int _selectedIndex = 0;
  bool _isLoading = true;

  String _id = '';
  String _name = '';
  String _email = '';
  String _contact = '';

  final Map<String, String?> _userVotes = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _carregarAlertas();
  }

  Future<void> _fetchUserData() async {
    try {
      Map<String, dynamic>? userData = await _preferencesService.getUserData();

      print(userData.toString());

      if (userData != null) {
        setState(() {
          _id = userData['id'] ?? 'No ID';
          _name = userData['name'] ?? 'No Name';
          _email = userData['email'] ?? 'No Email';
          _contact = userData['contato'] ?? 'No Contact';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _carregarAlertas() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final resultado = await _alertService.getAllAlerts();

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
          _isLoading = false;
        });

        _carregarVotosDoUsuario(alertas);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log("Erro ao carregar alertas: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _carregarVotosDoUsuario(
    List<Map<String, dynamic>> alertas,
  ) async {
    const String userId = "usuario_teste_123";

    for (var alerta in alertas) {
      try {
        final voteCheck = await _alertService.checkUserVote(
          alerta['id'],
          userId,
        );
        if (voteCheck['status'] == 200 && voteCheck['data'] != null) {
          final hasVoted = voteCheck['data']['hasVoted'] as bool;
          if (hasVoted) {
            setState(() {
              _userVotes[alerta['id']] = voteCheck['data']['voteType'];
            });
          }
        }
      } catch (e) {
        developer.log("Erro ao verificar voto do usuário: $e");
      }
    }
  }

  void _mostrarDetalhesAlerta(Map<String, dynamic> alerta) {
    final String alertaId = alerta['id'];
    final String? userVoteType = _userVotes[alertaId];

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
      final resultado = await _alertService.vote(alertaId, _id, true);

      if (resultado['status'] == 200) {
        if (resultado['data'] != null) {
          final newVoteType = _userVotes[alertaId] == 'up' ? null : 'up';

          setState(() {
            _userVotes[alertaId] = newVoteType;
          });

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
      developer.log("Erro ao dar upvote: $e");
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
      final resultado = await _alertService.vote(alertaId, _id, false);

      if (resultado['status'] == 200) {
        if (resultado['data'] != null) {
          final newVoteType = _userVotes[alertaId] == 'down' ? null : 'down';

          setState(() {
            _userVotes[alertaId] = newVoteType;
          });

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
      developer.log("Erro ao dar downvote: $e");
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
        _marcadores[index] = Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _mostrarDetalhesAlerta(alertaAtualizado),
            child: const Icon(Icons.warning, color: Colors.red, size: 40),
          ),
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

  Future<void> _criarAlerta(LatLng ponto, String? descricao) async {
    try {
      final resultado = await _alertService.createAlert(
        coordinates: ponto,
        userId: _id,
        description: descricao,
      );

      Navigator.pop(context);

      if (resultado['status'] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta criado com sucesso!')),
        );

        _carregarAlertas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resultado['message']}')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao criar alerta: $e')));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMapScreen();
      case 1:
        return _buildProfileScreen();
      default:
        return _buildMapScreen();
    }
  }

  Widget _buildMapScreen() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: _posicaoInicial,
        initialZoom: 15,
        onTap: (tapPosition, point) => _handleMapTap(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(markers: _marcadores),
      ],
    );
  }

  Widget _buildProfileScreen() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileItem(label: 'ID', value: _id),
          _buildProfileItem(label: 'Name', value: _name),
          _buildProfileItem(label: 'Email', value: _email),
          _buildProfileItem(label: 'Contact', value: _contact),
        ],
      ),
    );
  }

  Widget _buildProfileItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _selectedIndex == 0 ? 'Mapa de Alertas' : 'Perfil',
      ),
      body: _getBody(),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
