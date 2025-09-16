import 'package:flutter/material.dart';

class AlertDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> alerta;
  final String? userVoteType;
  final Function(Map<String, dynamic>, StateSetter) onUpvote;
  final Function(Map<String, dynamic>, StateSetter) onDownvote;

  const AlertDetailsDialog({
    Key? key,
    required this.alerta,
    required this.userVoteType,
    required this.onUpvote,
    required this.onDownvote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final imageUrl = alerta['imageUrl'];

        return AlertDialog(
          title: const Text('Detalhes do Alerta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Image.network(
                      imageUrl,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Não foi possível carregar a imagem.');
                      },
                    ),
                  ),
                Text('Descrição: ${alerta['description']}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => onUpvote(alerta, setState),
                      icon: const Icon(Icons.thumb_up),
                      label: Text('${alerta['ups']}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            userVoteType == 'up' ? Colors.green.shade800 : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => onDownvote(alerta, setState),
                      icon: const Icon(Icons.thumb_down),
                      label: Text('${alerta['downs']}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            userVoteType == 'down' ? Colors.red.shade800 : Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

