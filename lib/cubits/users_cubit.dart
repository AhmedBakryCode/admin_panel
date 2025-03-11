import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersCubit extends Cubit<UsersState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UsersCubit() : super(UsersInitial());

  Future<void> loadUsers() async {
    emit(UsersLoading());
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      List<Map<String, dynamic>> users = [];
      for (var doc in snapshot.docs) {
        users.add({
          'id': doc.id,
          'name': doc['id'],
          'isUsed': doc['isUsed'],
        });
      }
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> addUser(String name) async {
    try {
      await _firestore.collection('users').add({
        'id': name,
        'isUsed': false,
      });
      loadUsers();
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> updateUser(String id, String newName, bool newIsUsed) async {
    try {
      await _firestore.collection('users').doc(id).update({
        'id': newName,
        'isUsed': newIsUsed,
      });
      loadUsers();
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
      loadUsers();
    } catch (e) {
      emit(UsersError(e.toString()));
    }
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
