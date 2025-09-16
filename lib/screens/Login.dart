//tela para fazer login e cadastro de usuário

import 'package:buraco/services/UserPreferencesService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buraco/screens/Home.dart';
import 'package:buraco/screens/Register.dart';
import 'package:buraco/services/UserService.dart';
import 'package:buraco/components/CustomTextField.dart';
import 'package:buraco/components/CustomButton.dart';
import 'package:buraco/components/CustomAppBar.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomTextField(
                controller: _passwordController,
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomButton(text: 'Entrar', onPressed: _login),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );
              },
              child: const Text('Registrar-se'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    final response = await _userService.login(email, password);

    if (response['status'] == 200 && response['data'] != null) {
      // Fetch the Firebase User after successful login
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        var userPrefService = UserPreferencesService();
        await userPrefService.saveUserData({'uid': firebaseUser.uid, 'email': firebaseUser.email});

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Home()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário Firebase não encontrado após login.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Erro desconhecido')),
      );
    }
  }
}
