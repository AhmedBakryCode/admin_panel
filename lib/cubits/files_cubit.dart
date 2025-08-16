import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services.dart';

class FilesCubit extends Cubit<FilesState> {
  final String? courseName;
  final FirebaseStorageService _service = FirebaseStorageService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FilesCubit(this.courseName) : super(FilesInitial()) {
    loadFiles();
  }

  Future<void> loadFiles() async {
    emit(FilesLoading());
    try {
      List<Reference> files = await _service.getCourseFiles(courseName!);
      emit(FilesLoaded(files));
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> deleteFile(Reference fileRef) async {
    try {
      // Delete associated test links from Firestore
      await FirebaseFirestore.instance
          .collection('tests_links')
          .where('courseName', isEqualTo: courseName)
          .where('videoName', isEqualTo: fileRef.name)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      await fileRef.delete();
      loadFiles();
    } catch (e) {
      emit(FilesError("فشل حذف الملف"));
    }
  }

  Future<void> editFileName(Reference fileRef, String newName) async {
    try {
      Uint8List? fileData = await fileRef.getData();
      if (fileData != null) {
        await _storage.ref('$courseName/$newName').putData(fileData);
        // Update test links with new video name
        await FirebaseFirestore.instance
            .collection('tests_links')
            .where('courseName', isEqualTo: courseName)
            .where('videoName', isEqualTo: fileRef.name)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({'videoName': newName});
          }
        });
        await fileRef.delete();
        loadFiles();
      } else {
        emit(FilesError("فشل في إعادة تسمية الملف"));
      }
    } catch (e) {
      emit(FilesError("حدث خطأ أثناء إعادة التسمية"));
    }
  }

  Future<void> uploadFile(String fileName, Uint8List fileData) async {
    try {
      await _service.uploadFile(courseName!, fileName, fileData);
      loadFiles();
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> addTestLink(String videoName, String testLink) async {
    try {
      await FirebaseFirestore.instance.collection('tests_links').add({
        'courseName': courseName,
        'videoName': videoName,
        'testLink': testLink,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      emit(FilesError("فشل في إضافة رابط الاختبار"));
    }
  }
}

// States
abstract class FilesState {}

class FilesInitial extends FilesState {}

class FilesLoading extends FilesState {}

class FilesLoaded extends FilesState {
  final List<Reference> files;
  FilesLoaded(this.files);
}

class FilesSuccess extends FilesState {
  final String message;
  FilesSuccess(this.message);
}

class FilesError extends FilesState {
  final String message;
  FilesError(this.message);
}