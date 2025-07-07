import 'package:flutter/material.dart';
import '../../components/alert/AlertManager.dart';
import '../../services/AlertService.dart';
import '../../components/alert/AlertDetailsDialog.dart';

class AlertListScreen extends StatefulWidget {
  final String userId;

  const AlertListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AlertListScreen> createState() => _AlertListScreenState();
}

class _AlertListScreenState extends State<AlertListScreen> {
  final AlertService alertService = AlertService();
  late AlertManager _alertManager;
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _alertManager = AlertManager(
      alertService: alertService,
      userId: widget.userId,
    );
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _alertManager.getAllAlerts();

      if (result['status'] == 200 && result['data'] != null) {
        if (mounted) {
          setState(() {
            _alerts = List<Map<String, dynamic>>.from(result['data']);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar alertas: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadAlerts();
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    final String alertId = alert['id'];
    final String? userVoteType = _alertManager.userVotes[alertId];

    showDialog(
      context: context,
      builder: (context) => AlertDetailsDialog(
        alerta: alert,
        userVoteType: userVoteType,
        onUpvote: _handleUpvote,
        onDownvote: _handleDownvote,
      ),
    );
  }

  Future<void> _handleUpvote(
    Map<String, dynamic> alert,
    StateSetter dialogSetState,
  ) async {
    try {
      final alertId = alert['id'];
      final result = await _alertManager.vote(alertId, true);

      if (result['status'] == 200 && result['data'] != null) {
        dialogSetState(() {
          alert['ups'] = result['data']['ups'];
          alert['downs'] = result['data']['downs'];
        });

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Voto registrado!')));

        await _loadAlerts(); // Refresh the list
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao registrar voto: $e')));
    }
  }

  Future<void> _handleDownvote(
    Map<String, dynamic> alert,
    StateSetter dialogSetState,
  ) async {
    try {
      final alertId = alert['id'];
      final result = await _alertManager.vote(alertId, false);

      if (result['status'] == 200 && result['data'] != null) {
        dialogSetState(() {
          alert['ups'] = result['data']['ups'];
          alert['downs'] = result['data']['downs'];
        });

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Voto registrado!')));

        await _loadAlerts(); // Refresh the list
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao registrar voto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return AlertListItem(
                  alert: alert,
                  onTap: () => _showAlertDetails(alert),
                );
              },
            ),
    );
  }
}

class AlertListItem extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onTap;

  const AlertListItem({Key? key, required this.alert, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        title: Text(alert['description'] ?? 'Sem descrição'),
        subtitle: Text('Ups: ${alert['ups']} | Downs: ${alert['downs']}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

