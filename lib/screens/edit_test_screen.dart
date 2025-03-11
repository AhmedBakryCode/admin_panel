import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/tests_cubits.dart';

class EditTestScreen extends StatefulWidget {
  final String testId;
  final String currentTestName;
  final String currentVideoName;
  final List<Map<String, dynamic>> questions;

  EditTestScreen({
    required this.testId,
    required this.currentTestName,
    required this.currentVideoName,
    required this.questions,
  });

  @override
  _EditTestScreenState createState() => _EditTestScreenState();
}

class _EditTestScreenState extends State<EditTestScreen> {
  late TextEditingController _testNameController;
  late TextEditingController _videoNameController;
  late List<Map<String, dynamic>> _editedQuestions;

  @override
  void initState() {
    super.initState();
    _testNameController = TextEditingController(text: widget.currentTestName);
    _videoNameController = TextEditingController(text: widget.currentVideoName);
    _editedQuestions = List.from(widget.questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل الاختبار')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addNewQuestion,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Test Info
              _buildTestInfoForm(),
              SizedBox(height: 20),
              // Questions List
              ..._buildQuestionsList(),
              // Save Button
              ElevatedButton(
                onPressed: () => _saveChanges(context),
                child: Text('حفظ جميع التعديلات'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestInfoForm() {
    return Column(
      children: [
        TextFormField(
          controller: _testNameController,
          decoration: InputDecoration(labelText: 'اسم الاختبار'),
        ),
        TextFormField(
          controller: _videoNameController,
          decoration: InputDecoration(labelText: 'اسم الفيديو'),
        ),
      ],
    );
  }

  List<Widget> _buildQuestionsList() {
    return List.generate(_editedQuestions.length, (index) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text('السؤال ${index + 1}', style: TextStyle(fontSize: 18)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteQuestion(index),
                  ),
                ],
              ),
              _buildQuestionForm(index),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuestionForm(int questionIndex) {
    return Column(
      children: [
        TextFormField(
          initialValue: _editedQuestions[questionIndex]['question'],
          decoration: InputDecoration(labelText: 'السؤال'),
          onChanged: (value) =>
              _editedQuestions[questionIndex]['question'] = value,
        ),
        ...List.generate(
            4,
            (optionIndex) => TextFormField(
                  initialValue: _editedQuestions[questionIndex]['options']
                      [optionIndex],
                  decoration:
                      InputDecoration(labelText: 'الاختيار ${optionIndex + 1}'),
                  onChanged: (value) => _editedQuestions[questionIndex]
                      ['options'][optionIndex] = value,
                )),
        TextFormField(
          initialValue:
              (_editedQuestions[questionIndex]['correctAnswer'] + 1).toString(),
          decoration: InputDecoration(labelText: 'رقم الإجابة الصحيحة (1-4)'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              int correctAnswer = int.parse(value) - 1;
              if (correctAnswer >= 0 && correctAnswer < 4) {
                _editedQuestions[questionIndex]['correctAnswer'] =
                    correctAnswer;
              }
            }
          },
        ),
      ],
    );
  }

  void _addNewQuestion() {
    setState(() {
      _editedQuestions.add({
        'question': '',
        'options': ['', '', '', ''],
        'correctAnswer': 0,
      });
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      _editedQuestions.removeAt(index);
    });
  }

  void _saveChanges(BuildContext context) {
    // Validation
    if (_testNameController.text.isEmpty || _videoNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('اسم الاختبار والفيديو مطلوبان')));
      return;
    }

    for (var question in _editedQuestions) {
      if (question['question'].toString().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('يوجد سؤال بدون نص')));
        return;
      }
      for (var option in question['options']) {
        if (option.toString().isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('يوجد اختيارات فارغة')));
          return;
        }
      }
    }

    // Save to Firestore
    context.read<TestsCubit>().updateTest(
          widget.testId,
          _testNameController.text,
          _videoNameController.text,
          _editedQuestions,
        );

    Navigator.pop(context);
  }
}
