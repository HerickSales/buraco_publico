import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/AlertService.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Marker> _marcadores = [];
  final AlertService _alertService = AlertService();
  final LatLng _posicaoInicial = LatLng(-21.202248, -41.903281);
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  // Mapa para armazenar o estado de voto do usuário atual
  final Map<String, String?> _userVotes = {};
  
  @override
  void initState() {
    super.initState();
    _carregarAlertas();
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
              Marker(
                point: LatLng(lat, lng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _mostrarDetalhesAlerta(alerta),
                  child: const Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            );
          }
          _isLoading = false;
        });
        
        // Carregar os votos do usuário atual
        _carregarVotosDoUsuario(alertas);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar alertas: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _carregarVotosDoUsuario(List<Map<String, dynamic>> alertas) async {
    // ID de usuário fixo para testes
    const String userId = "usuario_teste_123";
    
    for (var alerta in alertas) {
      try {
        final voteCheck = await _alertService.checkUserVote(alerta['id'], userId);
        if (voteCheck['status'] == 200 && voteCheck['data'] != null) {
          final hasVoted = voteCheck['data']['hasVoted'] as bool;
          if (hasVoted) {
            setState(() {
              _userVotes[alerta['id']] = voteCheck['data']['voteType'];
            });
          }
        }
      } catch (e) {
        print("Erro ao verificar voto do usuário: $e");
      }
    }
  }
  
  void _mostrarDetalhesAlerta(Map<String, dynamic> alerta) {
    final String alertaId = alerta['id'];
    final String? userVoteType = _userVotes[alertaId];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Detalhes do Alerta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descrição: ${alerta['description']}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _darUpvote(alerta, setState),
                      icon: const Icon(Icons.thumb_up),
                      label: Text('${alerta['ups']}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userVoteType == 'up' ? Colors.green.shade800 : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _darDownvote(alerta, setState),
                      icon: const Icon(Icons.thumb_down),
                      label: Text('${alerta['downs']}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userVoteType == 'down' ? Colors.red.shade800 : Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          );
        }
      ),
    );
  }
  
  Future<void> _darUpvote(Map<String, dynamic> alerta, StateSetter dialogSetState) async {
    try {
      final alertaId = alerta['id'];
      final resultado = await _alertService.incrementUp(alertaId);
      
      if (resultado['status'] == 200) {
        if (resultado['data'] != null) {
          // Atualizar o estado do voto do usuário
          final newVoteType = _userVotes[alertaId] == 'up' ? null : 'up';
          
          setState(() {
            _userVotes[alertaId] = newVoteType;
          });
          
          // Atualizar os contadores localmente
          dialogSetState(() {
            alerta['ups'] = resultado['data']['ups'];
            alerta['downs'] = resultado['data']['downs'];
          });
          
          // Atualizar o marcador no mapa
          _atualizarMarcador(alertaId, alerta);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voto registrado!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resultado['message']}')),
        );
      }
    } catch (e) {
      print("Erro ao dar upvote: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar voto: $e')),
      );
    }
  }
  
  Future<void> _darDownvote(Map<String, dynamic> alerta, StateSetter dialogSetState) async {
    try {
      final alertaId = alerta['id'];
      final resultado = await _alertService.incrementDown(alertaId);
      
      if (resultado['status'] == 200) {
        if (resultado['data'] != null) {
          // Atualizar o estado do voto do usuário
          final newVoteType = _userVotes[alertaId] == 'down' ? null : 'down';
          
          setState(() {
            _userVotes[alertaId] = newVoteType;
          });
          
          // Atualizar os contadores localmente
          dialogSetState(() {
            alerta['ups'] = resultado['data']['ups'];
            alerta['downs'] = resultado['data']['downs'];
          });
          
          // Atualizar o marcador no mapa
          _atualizarMarcador(alertaId, alerta);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voto registrado!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resultado['message']}')),
        );
      }
    } catch (e) {
      print("Erro ao dar downvote: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar voto: $e')),
      );
    }
  }
  
  void _atualizarMarcador(String alertaId, Map<String, dynamic> alertaAtualizado) {
    // Encontrar o índice do marcador
    final index = _marcadores.indexWhere((marker) {
      if (marker.child is GestureDetector) {
        final gestureDetector = marker.child as GestureDetector;
        if (gestureDetector.onTap != null) {
          // Este é apenas um hack para identificar o marcador correto
          // Idealmente, você teria um ID no marcador
          return true;
        }
      }
      return false;
    });
    
    if (index >= 0) {
      // Atualizar o marcador com os novos dados
      final lat = alertaAtualizado['latitude'] as double;
      final lng = alertaAtualizado['longitude'] as double;
      
      setState(() {
        _marcadores[index] = Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _mostrarDetalhesAlerta(alertaAtualizado),
            child: const Icon(
              Icons.warning,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      });
    }
  }

  void _handleMapTap(LatLng point) {
    _abrirModalCriarAlerta(point);
  }
  
  void _abrirModalCriarAlerta(LatLng ponto) {
    final descricaoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Novo Alerta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Você está criando um alerta neste local.'),
            const SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _criarAlerta(ponto, descricaoController.text),
            child: const Text('Criar Alerta'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _criarAlerta(LatLng ponto, String? descricao) async {
    try {
      // ID de usuário fixo para testes
      const String userId = "usuario_teste_123";
      
      final resultado = await _alertService.createAlert(
        coordinates: ponto,
        userId: userId,
        description: descricao,
      );
      
      Navigator.pop(context);
      
      if (resultado['status'] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta criado com sucesso!')),
        );
        
        // Recarregar os alertas para mostrar o novo
        _carregarAlertas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resultado['message']}')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar alerta: $e')),
      );
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
        MarkerLayer(
          markers: _marcadores,
        ),
      ],
    );
  }

  Widget _buildProfileScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.person, size: 100),
          SizedBox(height: 20),
          Text(
            'Perfil do Usuário',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 10),
          Text('Aqui você poderá ver suas informações de perfil'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0 
          ? const Text('Mapa de Alertas') 
          : const Text('Perfil'),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _carregarAlertas,
              tooltip: 'Recarregar alertas',
            ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
