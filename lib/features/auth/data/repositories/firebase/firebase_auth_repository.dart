import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:student_hub/features/auth/domain/entities/user.dart';

/// Firebase реализация AuthRepository
/// Требует настройки Firebase перед использованием
class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      return User.fromJson(userDoc.data()!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    required String faculty,
    required String group,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = User(
        id: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        faculty: faculty,
        group: group,
        avatarUrl: 'https://i.pravatar.cc/150',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuth register error: ${e.code} ${e.message}');
      throw Exception(e.message ?? 'Firebase auth error');
    } catch (e, stack) {
      print('Firestore registration error: $e');
      print(stack);
      if (e is firebase_auth.FirebaseAuthException) {
        throw Exception(e.message ?? 'Firebase auth error');
      }
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      return User.fromJson(userDoc.data()!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String faculty,
    required String group,
  }) async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('Not authenticated');
    }

    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    await userRef.update({
      'firstName': firstName,
      'lastName': lastName,
      'faculty': faculty,
      'group': group,
    });

    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw Exception('User profile not found');
    }

    return User.fromJson(userDoc.data()!);
  }
}
