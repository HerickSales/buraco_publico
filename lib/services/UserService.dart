import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Criação de usuário
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      );

      String uid = userCredential.user!.uid;

      await firestore.collection('users').doc(uid).set({
        'name': userData['name'],
        'contact': userData['contact'],
        'email': userData['email'],
        'uid': uid,
      });

      return {
        'message': 'Usuário criado com sucesso',
        'status': 201,
        'data': {'uid': uid, 'email': userData['email']},
      };
    } on FirebaseAuthException catch (e) {
      return {
        'message': e.message ?? 'Erro ao criar usuário',
        'status': 500,
        'data': null,
      };
    } catch (e) {
      return {
        'message': 'Erro desconhecido ao criar usuário: $e',
        'status': 500,
        'data': null,
      };
    }
  }

  // Login do usuário
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      final userData = await getUserData(uid);

      return {
        'message': 'Login bem-sucedido',
        'status': 200,
        'data': userData,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Nenhum usuário encontrado para este email.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta fornecida para este usuário.';
      } else {
        message = e.message ?? 'Erro no login';
      }
      return {'message': message, 'status': 401, 'data': null};
    } catch (e) {
      return {'message': 'Erro desconhecido no login: $e', 'status': 500, 'data': null};
    }
  }

  // Buscar dados de um usuário por UID
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      return null;
    }
  }
}
