
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<String>> getCourses() async {
    try {
      ListResult result = await _storage.ref('courses').listAll();
      return result.prefixes.map((folder) => folder.name).toList();
    } catch (e) {
      throw Exception('فشل في جلب الكورسات');
    }
  }

  Future<void> createCourse(String courseName) async {
    try {
      await _storage.ref('courses/$courseName').child('.keep').putData(Uint8List(0));
    } catch (e) {
      throw Exception('فشل في إنشاء الكورس');
    }
  }

  Future<List<Reference>> getCourseFiles(String courseName) async {
    try {
      ListResult result = await _storage.ref('courses/$courseName').listAll();
      return result.items;
    } catch (e) {
      throw Exception('فشل في جلب الملفات');
    }
  }

  Future<void> uploadFile(String courseName, String fileName, Uint8List fileData) async {
    try {
      await _storage.ref('courses/$courseName/$fileName').putData(fileData);
    } catch (e) {
      throw Exception('فشل في رفع الملف');
    }
  }
}