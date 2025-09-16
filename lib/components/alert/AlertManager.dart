import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:developer' as developer;
import '../../services/AlertService.dart';

class AlertManager extends ChangeNotifier {
  final AlertService _alertService;
  final String userId;
  final Map<String, String?> _userVotes = {};
  bool _isLoading = false;

  AlertManager({
    required AlertService alertService,
    required this.userId,
  }) : _alertService = alertService;

  bool get isLoading => _isLoading;
  Map<String, String?> get userVotes => _userVotes;

  Future<Map<String, dynamic>> getAllAlerts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final resultado = await _alertService.getAllAlerts();
      
      if (resultado['status'] == 200 && resultado['data'] != null) {
        final alertas = resultado['data'] as List<Map<String, dynamic>>;
        await _loadUserVotes(alertas);
      }

      _isLoading = false;
      notifyListeners();
      
      return resultado;
    } catch (e) {
      developer.log("Erro ao carregar alertas: $e");
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadUserVotes(List<Map<String, dynamic>> alerts) async {
    for (var alert in alerts) {
      try {
        final voteCheck = await _alertService.checkUserVote(alert['id'], userId);
        if (voteCheck['status'] == 200 && voteCheck['data'] != null) {
          final hasVoted = voteCheck['data']['hasVoted'] as bool;
          if (hasVoted) {
            _userVotes[alert['id']] = voteCheck['data']['voteType'];
          }
        }
      } catch (e) {
        developer.log("Erro ao verificar voto do usuário: $e");
      }
    }
  }

  Future<Map<String, dynamic>> vote(
    String alertId,
    bool isUpvote,
  ) async {
    try {
      final resultado = await _alertService.vote(alertId, userId, isUpvote);

      if (resultado['status'] == 200 && resultado['data'] != null) {
        final newVoteType = _userVotes[alertId] == (isUpvote ? 'up' : 'down') 
            ? null 
            : (isUpvote ? 'up' : 'down');
        
        _userVotes[alertId] = newVoteType;
        notifyListeners();
      }

      return resultado;
    } catch (e) {
      developer.log("Erro ao registrar voto: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createAlert({
    required LatLng coordinates,
    String? description,
    String? imageUrl,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _alertService.createAlert(
        coordinates: coordinates,
        userId: userId,
        description: description,
        imageUrl: imageUrl,
      );

      if (result['status'] == 201) {
        final alertResult = await _alertService.getAllAlerts();
        if (alertResult['status'] == 200 && alertResult['data'] != null) {
          final alertas = alertResult['data'] as List<Map<String, dynamic>>;
          await _loadUserVotes(alertas);
        }
      }

      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      developer.log("Erro ao criar alerta: $e");
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

