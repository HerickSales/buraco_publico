import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CreateAlertDialog extends StatelessWidget {
  final LatLng point;
  final Function(LatLng, String?) onCreateAlert;

  const CreateAlertDialog({
    Key? key,
    required this.point,
    required this.onCreateAlert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final descricaoController = TextEditingController();

    return AlertDialog(
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
          onPressed: () {
            onCreateAlert(point, descricaoController.text);
            Navigator.pop(context);
          },
          child: const Text('Criar Alerta'),
        ),
      ],
    );
  }
}

