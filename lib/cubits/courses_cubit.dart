import 'package:flutter_bloc/flutter_bloc.dart';

import '../services.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final FirebaseStorageService _service = FirebaseStorageService();

  CoursesCubit() : super(CoursesInitial());

  Future<void> loadCourses() async {
    emit(CoursesLoading());
    try {
      List<String> courses = await _service.getCourses();
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> addCourse(String name) async {
    try {
      await _service.createCourse(name);
      loadCourses();
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}

// States
abstract class CoursesState {}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<String> courses;
  CoursesLoaded(this.courses);
}

class CoursesError extends CoursesState {
  final String message;
  CoursesError(this.message);
}