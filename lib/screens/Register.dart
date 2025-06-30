import 'package:flutter/material.dart';


import 'package:buraco/services/UserService.dart';

class Register extends StatelessWidget {
  Register({Key? key}) : super(key: key);

  final UserService _userService = UserService();
  final Map<String, dynamic> userData = {
    'name': '',
    'email': '',
    'contact': '',
    'password': '',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nome'),
              onChanged: (value) {
                userData['name'] = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                userData['email'] = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Contato'),
              onChanged: (value) {
                userData['contact'] = value;
              },
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
              onChanged: (value) {
                userData['password'] = value;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                var res = await _userService.createUser(userData);
                print(res);
                if (res['status'] == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message'])),
                  );
                  Navigator.pop(context); // Volta para a tela de login
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message'])),
                  );
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );

  }
}