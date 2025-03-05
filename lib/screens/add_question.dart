import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/tests_cubits.dart';

class AddQuestionsScreen extends StatefulWidget {
  final String testName;
  final String videoName;

  AddQuestionsScreen({required this.testName, required this.videoName});

  @override
  _AddQuestionsScreenState createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> _questions = [];

  void _addQuestion() {
    _questions.add({
      'question': '',
      'options': ['', '', '', ''],
      'correctAnswer': 0,
    });
    _pageController.jumpToPage(_questions.length - 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة أسئلة')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addQuestion,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _questions.length,
        itemBuilder: (context, index) => _buildQuestionForm(index),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () => _saveTest(context),
          child: Text('إنهاء وحفظ الاختبار'),
        ),
      ],
    );
  }

  Widget _buildQuestionForm(int index) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'السؤال'),
            onChanged: (value) => _questions[index]['question'] = value,
          ),
          ...List.generate(4, (optionIndex) => TextFormField(
            decoration: InputDecoration(labelText: 'الاختيار ${optionIndex + 1}'),
            onChanged: (value) => _questions[index]['options'][optionIndex] = value,
          )),
          TextFormField(
            decoration: InputDecoration(labelText: 'رقم الإجابة الصحيحة (1-4)'),
            keyboardType: TextInputType.number,
            onChanged: (value) => _questions[index]['correctAnswer'] = int.parse(value) - 1,
          ),
        ],
      ),
    );
  }

  void _saveTest(BuildContext context) {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('أضف على الأقل سؤال واحد')));
      return;
    }

    context.read<TestsCubit>().addTest(widget.testName, widget.videoName, _questions);
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}