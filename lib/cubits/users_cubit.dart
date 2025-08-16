import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';

import '../services.dart';

class UsersCubit extends Cubit<UsersState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  UsersCubit() : super(UsersInitial());

  Future<void> loadUsers() async {
    emit(UsersLoading());
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      List<Map<String, dynamic>> users = [];
      for (var doc in snapshot.docs) {
        users.add({
          'id': doc.id,
          'name': doc['name'], // Changed from 'id' to 'name' to match UI
          'code': doc['code'],
          'courses': Map<String, bool>.from(doc['courses']),
        });
      }
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> addUser(
      String name, String code, Map<String, bool> courseUsage) async {
    try {
      await _firestore.collection('users').add({
        'name': name,
        'code': code,
        'courses': courseUsage,
      });
      await loadUsers();
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> updateUser(String id, String name, String code,
      Map<String, bool> courseUsage) async {
    try {
      await _firestore.collection('users').doc(id).update({
        'name': name,
        'code': code,
        'courses': courseUsage,
      });
      await loadUsers();
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
      await loadUsers();
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  // Helper method to get available courses from FirebaseStorageService
  Future<List<String>> getAvailableCourses() async {
    try {
      return await _storageService.getCourses();
    } catch (e) {
      emit(UsersError('فشل في جلب الكورسات: $e'));
      return [];
    }
  }

  // Helper method to generate a unique code
  String generateUniqueCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
      ),
    );
  }
}

// States
abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<Map<String, dynamic>> users;
  UsersLoaded(this.users);
}

class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}
