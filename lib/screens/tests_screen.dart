import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/tests_cubits.dart';
import 'add_question.dart';

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
              itemBuilder: (context, index) => ListTile(
                title: Text(state.tests[index]['testName']),
                subtitle: Text(state.tests[index]['videoName']),
              ),
            );
          } else if (state is TestsError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('اضغط + لإضافة اختبار جديد'));
        },
      ),
    );
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
              if (testNameController.text.isNotEmpty && videoNameController.text.isNotEmpty) {
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
}