import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class AlertService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'alerts';
  final String votesCollectionName = 'votes';

  // CREATE - Criar um novo alerta
  Future<Map<String, dynamic>> createAlert({
    required LatLng coordinates,
    required String userId,
    String? description,
  }) async {
    try {
      // Criando um novo alerta com os valores padrão para ups e downs
      DocumentReference docRef = await firestore
          .collection(collectionName)
          .add({
            'latitude': coordinates.latitude,
            'longitude': coordinates.longitude,
            'userId': userId,
            'description': description ?? '',
            'ups': 0,
            'downs': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return {
        'message': 'Alerta criado com sucesso',
        'status': 201,
        'data': {
          'id': docRef.id,
          'latitude': coordinates.latitude,
          'longitude': coordinates.longitude,
          'userId': userId,
          'description': description ?? '',
          'ups': 0,
          'downs': 0,
        },
      };
    } catch (e) {
      return {
        'message': 'Erro ao criar alerta: $e',
        'status': 500,
        'data': null,
      };
    }
  }

  // READ - Obter um alerta pelo ID
  Future<Map<String, dynamic>> getAlertById(String alertId) async {
    try {
      DocumentSnapshot doc = await firestore
          .collection(collectionName)
          .doc(alertId)
          .get();

      if (!doc.exists) {
        return {
          'message': 'Alerta não encontrado',
          'status': 404,
          'data': null,
        };
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      return {'message': 'Alerta encontrado', 'status': 200, 'data': data};
    } catch (e) {
      return {
        'message': 'Erro ao buscar alerta: $e',
        'status': 500,
        'data': null,
      };
    }
  }

  // READ - Obter todos os alertas
  Future<Map<String, dynamic>> getAllAlerts() async {
    try {
      QuerySnapshot snapshot = await firestore.collection(collectionName).get();

      List<Map<String, dynamic>> alerts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      return {
        'message': 'Alertas recuperados com sucesso',
        'status': 200,
        'data': alerts,
      };
    } catch (e) {
      return {
        'message': 'Erro ao buscar alertas: $e',
        'status': 500,
        'data': null,
      };
    }
  }

  // CHECK - Verificar se o usuário já votou no alerta
  Future<Map<String, dynamic>> checkUserVote(
    String alertId,
    String userId,
  ) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection(votesCollectionName)
          .where('alertId', isEqualTo: alertId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'message': 'Usuário não votou neste alerta',
          'status': 200,
          'data': {'hasVoted': false, 'voteType': null},
        };
      }

      Map<String, dynamic> voteData =
          snapshot.docs.first.data() as Map<String, dynamic>;

      return {
        'message': 'Voto encontrado',
        'status': 200,
        'data': {'hasVoted': true, 'voteType': voteData['voteType']},
      };
    } catch (e) {
      return {
        'message': 'Erro ao verificar voto: $e',
        'status': 500,
        'data': null,
      };
    }
  }

  // UPDATE - Votar (up ou down)
  Future<Map<String, dynamic>> vote(
    String alertId,
    String userId,
    bool isUpvote,
  ) async {
    try {
      final voteCheck = await checkUserVote(alertId, userId);
      final hasVoted = voteCheck['data']?['hasVoted'] ?? false;
      final previousVoteType = voteCheck['data']?['voteType'];

      return await firestore.runTransaction((transaction) async {
        DocumentReference alertRef = firestore
            .collection(collectionName)
            .doc(alertId);
        DocumentSnapshot alertSnapshot = await transaction.get(alertRef);

        if (!alertSnapshot.exists) {
          return {
            'message': 'Alerta não encontrado',
            'status': 404,
            'data': null,
          };
        }

        Map<String, dynamic> alertData =
            alertSnapshot.data() as Map<String, dynamic>;
        int ups = alertData['ups'] ?? 0;
        int downs = alertData['downs'] ?? 0;

        if (hasVoted) {
          QuerySnapshot voteSnapshot = await firestore
              .collection(votesCollectionName)
              .where('alertId', isEqualTo: alertId)
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

          DocumentReference voteRef = voteSnapshot.docs.first.reference;

          if ((previousVoteType == 'up' && isUpvote) ||
              (previousVoteType == 'down' && !isUpvote)) {
            transaction.delete(voteRef);

            if (previousVoteType == 'up') {
              ups--;
            } else {
              downs--;
            }

            transaction.update(alertRef, {
              'ups': ups,
              'downs': downs,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            return {
              'message': 'Voto removido',
              'status': 200,
              'data': {'ups': ups, 'downs': downs},
            };
          } else {
            // Mudar tipo de voto
            transaction.update(voteRef, {
              'voteType': isUpvote ? 'up' : 'down',
              'updatedAt': FieldValue.serverTimestamp(),
            });

            // Atualizar contadores
            if (isUpvote) {
              ups++;
              downs--;
            } else {
              downs++;
              ups--;
            }
          }
        } else {
          // Novo voto
          DocumentReference voteRef = firestore
              .collection(votesCollectionName)
              .doc();
          transaction.set(voteRef, {
            'alertId': alertId,
            'userId': userId,
            'voteType': isUpvote ? 'up' : 'down',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Atualizar contadores
          if (isUpvote) {
            ups++;
          } else {
            downs++;
          }
        }

        // Atualizar alerta
        transaction.update(alertRef, {
          'ups': ups,
          'downs': downs,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return {
          'message': 'Voto registrado com sucesso',
          'status': 200,
          'data': {'ups': ups, 'downs': downs},
        };
      });
    } catch (e) {
      return {
        'message': 'Erro ao registrar voto: $e',
        'status': 500,
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> deleteAlert(String alertId) async {
    try {
      await firestore.collection(collectionName).doc(alertId).delete();

      return {
        'message': 'Alerta excluído com sucesso',
        'status': 200,
        'data': null,
      };
    } catch (e) {
      return {
        'message': 'Erro ao excluir alerta: $e',
        'status': 500,
        'data': null,
      };
    }
  }
}
