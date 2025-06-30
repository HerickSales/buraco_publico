//tela para fazer login e cadastro de usuário

import 'package:flutter/material.dart';
import 'package:buraco/screens/Home.dart';
import 'package:buraco/screens/Register.dart';
import 'package:buraco/services/UserService.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}
class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Home()),
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response['message'] ?? 'Erro desconhecido')));
  }
}
}