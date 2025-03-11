import 'package:admin_panel/cubits/files_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cubits/courses_cubit.dart';
import 'cubits/tests_cubits.dart';
import 'cubits/users_cubit.dart';
import 'screens/courses_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UsersCubit()..loadUsers()),
        BlocProvider(create: (context) => TestsCubit()..loadTests()),
        BlocProvider(create: (context) => CoursesCubit()..loadCourses()),
        // BlocProvider(create: (context) => FilesCubit()..loadFiles()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
