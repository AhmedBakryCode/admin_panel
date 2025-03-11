import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/tests_cubits.dart';
import 'add_question.dart';
import 'edit_test_screen.dart';

class TestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الاختبارات')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showCreateTestDialog(context),
      ),
      body: BlocBuilder<TestsCubit, TestsState>(
        builder: (context, state) {
          if (state is TestsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TestsLoaded) {
            return ListView.builder(
              itemCount: state.tests.length,
              itemBuilder: (context, index) =>
                  _buildTestItem(context, state.tests[index]),
            );
          } else if (state is TestsError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('اضغط + لإضافة اختبار جديد'));
        },
      ),
    );
  }

  Widget _buildTestItem(BuildContext context, Map<String, dynamic> test) {
    return ListTile(
      title: Text(test['testName']),
      subtitle: Text('الفيديو: ${test['videoName']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _navigateToEditTest(context, test),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteTest(context, test['id']),
          ),
        ],
      ),
    );
  }

  void _deleteTest(BuildContext context, String testId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الاختبار'),
        content: Text('هل أنت متأكد من حذف هذا الاختبار؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<TestsCubit>().deleteTest(testId);
              Navigator.pop(context);
            },
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditTest(BuildContext context, Map<String, dynamic> test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTestScreen(
          testId: test['id'],
          currentTestName: test['testName'],
          currentVideoName: test['videoName'],
          questions: List<Map<String, dynamic>>.from(test['questions']),
        ),
      ),
    );
  }
}

void _showCreateTestDialog(BuildContext context) {
  TextEditingController testNameController = TextEditingController();
  TextEditingController videoNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('إنشاء اختبار جديد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: testNameController,
            decoration: InputDecoration(labelText: 'اسم الاختبار'),
          ),
          TextFormField(
            controller: videoNameController,
            decoration: InputDecoration(labelText: 'اسم الفيديو'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            if (testNameController.text.isNotEmpty &&
                videoNameController.text.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddQuestionsScreen(
                    testName: testNameController.text,
                    videoName: videoNameController.text,
                  ),
                ),
              );
            }
          },
          child: Text('متابعة'),
        ),
      ],
    ),
  );
}
