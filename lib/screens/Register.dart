import 'package:flutter/material.dart';


import 'package:buraco/services/UserService.dart';
import 'package:buraco/components/CustomTextField.dart';
import 'package:buraco/components/CustomButton.dart';
import 'package:buraco/components/CustomAppBar.dart';

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
      appBar: const CustomAppBar(
        title: 'Registrar',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomTextField(
                controller: TextEditingController(),
                labelText: 'Nome',
                prefixIcon: const Icon(Icons.person),
                onChanged: (value) {
                  userData['name'] = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomTextField(
                controller: TextEditingController(),
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                onChanged: (value) {
                  userData['email'] = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomTextField(
                controller: TextEditingController(),
                labelText: 'Contato',
                prefixIcon: const Icon(Icons.phone),
                onChanged: (value) {
                  userData['contact'] = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomTextField(
                controller: TextEditingController(),
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock),
                obscureText: true,
                onChanged: (value) {
                  userData['password'] = value;
                },
              ),
            ),
            CustomButton(
              text: 'Registrar',
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
            ),
          ],
        ),
      ),
    );

  }
}
