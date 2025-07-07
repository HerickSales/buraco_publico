import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

