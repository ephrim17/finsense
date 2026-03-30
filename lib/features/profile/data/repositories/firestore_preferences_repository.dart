import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../dtos/user_preferences_dto.dart';

class FirestorePreferencesRepository implements PreferencesRepository {
  FirestorePreferencesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<UserPreferences> watchPreferences(String userId) {
    return _firestore.doc(FirestorePaths.settings(userId)).snapshots().map((
      doc,
    ) {
      final data = doc.data();
      if (data == null) {
        return const UserPreferences();
      }
      return UserPreferencesDto.fromJson(data).toDomain();
    });
  }

  @override
  Future<void> savePreferences(String userId, UserPreferences preferences) {
    return _firestore
        .doc(FirestorePaths.settings(userId))
        .set(
          UserPreferencesDto.fromDomain(preferences).toJson(),
          SetOptions(merge: true),
        );
  }
}
