import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestsCubit extends Cubit<TestsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TestsCubit() : super(TestsInitial());

  Future<void> loadTests() async {
    emit(TestsLoading());
    try {
      QuerySnapshot snapshot = await _firestore.collection('tests').get();
      List<Map<String, dynamic>> tests = [];
      for (var doc in snapshot.docs) {
        tests.add({
          'id': doc.id, // إضافة الـ ID هنا
          ...doc.data() as Map<String, dynamic>,
        });
      }
      emit(TestsLoaded(tests));
    } catch (e) {
      emit(TestsError(e.toString()));
    }
  }

  Future<void> addTest(String testName, String videoName,
      List<Map<String, dynamic>> questions) async {
    try {
      await _firestore.collection('tests').add({
        'testName': testName,
        'videoName': videoName,
        'questions': questions,
        'createdAt': FieldValue.serverTimestamp(),
      });
      loadTests();
    } catch (e) {
      emit(TestsError(e.toString()));
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      await _firestore.collection('tests').doc(testId).delete();
      loadTests();
    } catch (e) {
      emit(TestsError(e.toString()));
    }
  }

  Future<void> updateTest(
    String testId,
    String testName,
    String videoName,
    List<Map<String, dynamic>> questions,
  ) async {
    try {
      await _firestore.collection('tests').doc(testId).update({
        'testName': testName,
        'videoName': videoName,
        'questions': questions, // تم إرسال الأسئلة المعدلة
      });
      loadTests();
    } catch (e) {
      emit(TestsError(e.toString()));
    }
  }
}

// States
abstract class TestsState {}

class TestsInitial extends TestsState {}

class TestsLoading extends TestsState {}

class TestsLoaded extends TestsState {
  final List<Map<String, dynamic>> tests;
  TestsLoaded(this.tests);
}

class TestsError extends TestsState {
  final String message;
  TestsError(this.message);
}
