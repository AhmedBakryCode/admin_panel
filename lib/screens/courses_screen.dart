import 'package:admin_panel/cubits/files_cubit.dart';
import 'package:admin_panel/screens/file_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/courses_cubit.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الكورسات')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddCourseDialog(context),
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CoursesLoaded) {
            return ListView.builder(
              itemCount: state.courses.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(state.courses[index]),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => FilesCubit(state.courses[index]),
                      child: FilesScreen(),
                    ),
                  ),
                ),
              ),
            );
          } else if (state is CoursesError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('اضغط + لإضافة كورس جديد'));
        },
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة كورس جديد'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<CoursesCubit>().addCourse(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }
}