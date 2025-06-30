import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Criação de usuário
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      await firestore.collection('users').add({
        'name': userData['name'],
        'contato': userData['contact'], // cuidado no frontend para usar 'contato' também
        'email': userData['email'],
        'password': userData['password'],
      });
      return {
        'message': 'Usuário criado com sucesso',
        'status': 201,
        'data': null,
      };
    } catch (e) {
      return {
        'message': 'Erro ao criar usuário: $e',
        'status': 500,
        'data': null,
      };
    }
  }

  // Login do usuário
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final usuario = await getUserByEmail(email);

      if (usuario == null) {
        return {
          'message': 'Usuário não encontrado',
          'status': 404,
          'data': null,
        };
      }

      if (usuario['password'] == password) {
        return {
          'message': 'Login bem-sucedido',
          'status': 200,
          'data': usuario,
        };
      } else {
        return {
          'message': 'Senha incorreta',
          'status': 401,
          'data': null,
        };
      }
    } catch (e) {
      return {
        'message': 'Erro no login: $e',
        'status': 500,
        'data': null,
      };
    }
  }

  // Buscar dados de um usuário por e-mail
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        return null;
      }
      final doc = snapshot.docs.first;
      return doc.data();
    } catch (e) {
      return null;
    }
  }
}
