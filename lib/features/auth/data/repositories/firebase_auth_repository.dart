import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dtos/user_profile_dto.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<UserProfile?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }

      final doc = await _firestore.doc(FirestorePaths.user(user.uid)).get();
      if (doc.exists) {
        return UserProfileDto.fromFirestore(doc).toDomain();
      }

      final profile = UserProfile(
        id: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? 'FinSense User',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _upsertProfile(profile);
      return profile;
    });
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final doc = await _firestore.doc(FirestorePaths.user(user.uid)).get();
    if (!doc.exists) {
      return UserProfile(
        id: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? 'FinSense User',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return UserProfileDto.fromFirestore(doc).toDomain();
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .doc(FirestorePaths.user(credential.user!.uid))
        .get();
    return UserProfileDto.fromFirestore(doc).toDomain();
  }

  @override
  Future<UserProfile> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(fullName);

    final profile = UserProfile(
      id: credential.user!.uid,
      email: email,
      fullName: fullName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _upsertProfile(profile);
    return profile;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Future<void> _upsertProfile(UserProfile profile) async {
    final dto = UserProfileDto.fromDomain(profile);
    await _firestore
        .doc(FirestorePaths.user(profile.id))
        .set(dto.toFirestore(), SetOptions(merge: true));
  }
}
