import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/lineup.dart';

/// Bản sao đội hình trên Firestore: `users/{uid}/lineups/{lineupId}`.
/// Quyền truy cập: xem `firestore.rules`.
class LineupFirestoreService {
  LineupFirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('lineups');

  Future<List<Lineup>> fetchAll(String uid) async {
    final snap = await _col(uid).get();
    return snap.docs.map((d) => Lineup.fromMap(d.data())).toList();
  }

  Future<void> upsert(Lineup lineup) => _col(lineup.uid).doc(lineup.id).set(lineup.toMap());

  Future<void> delete(String uid, String id) => _col(uid).doc(id).delete();
}
