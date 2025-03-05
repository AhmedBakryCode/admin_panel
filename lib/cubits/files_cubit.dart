import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../services.dart';

class FilesCubit extends Cubit<FilesState> {
  final String courseName;
  final FirebaseStorageService _service = FirebaseStorageService();

  FilesCubit(this.courseName) : super(FilesInitial()) {
    loadFiles();
  }

  Future<void> loadFiles() async {
    emit(FilesLoading());
    try {
      List<Reference> files = await _service.getCourseFiles(courseName);
      emit(FilesLoaded(files));
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> uploadFile(String fileName, Uint8List fileData) async {
    try {
      await _service.uploadFile(courseName, fileName, fileData);
      loadFiles();
    } catch (e) {
      emit(FilesError(e.toString()));
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

class FilesError extends FilesState {
  final String message;
  FilesError(this.message);
}