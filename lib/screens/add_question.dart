import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../cubits/tests_cubits.dart';

class AddQuestionsScreen extends StatefulWidget {
  final String testName;
  final String videoName;
  final String? testId; // جديد: معرف الاختبار للتعديل
  final List<Map<String, dynamic>>? existingQuestions; // جديد: الأسئلة الموجودة

  AddQuestionsScreen({
    required this.testName,
    required this.videoName,
    this.testId,
    this.existingQuestions,
  });

  @override
  _AddQuestionsScreenState createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    // تهيئة الأسئلة من البيانات الموجودة إذا كانت في وضع التعديل
    _questions = widget.existingQuestions ?? [];
  }

  void _saveTest(BuildContext context) {
    if (widget.testId == null) {
      // حالة الإضافة الجديدة
      context
          .read<TestsCubit>()
          .addTest(widget.testName, widget.videoName, _questions);
    } else {
      // حالة التعديل
      context.read<TestsCubit>().updateTest(
          widget.testId!, widget.testName, widget.videoName, _questions);
    }
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _addQuestion() {
    _questions.add({
      'question': '',
      'options': ['', '', '', ''],
      'correctAnswer': 0,
      'imageUrl': null, // لتخزين رابط الصورة إذا تم رفعها
    });
    _pageController.jumpToPage(_questions.length - 1);
    setState(() {});
  }

  Future<void> _pickAndUploadImage(int questionIndex) async {
    try {
      // استخدام withData: false للتأكيد على استخدام الـ path فقط
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;

      PlatformFile file = result.files.first;
      if (file.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("مسار الملف غير متاح")),
        );
        return;
      }

      // قراءة بيانات الملف من path
      Uint8List fileBytes;
      try {
        fileBytes = await File(file.path!).readAsBytes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل قراءة بيانات الصورة من المسار")),
        );
        return;
      }

      // توليد اسم فريد للصورة
      String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      // رفع الصورة إلى Firebase Storage في مجلد "tests"
      Reference storageRef =
          FirebaseStorage.instance.ref().child('tests').child(uniqueFileName);
      UploadTask uploadTask = storageRef.putData(fileBytes);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _questions[questionIndex]['imageUrl'] = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم رفع الصورة بنجاح")),
      );
    } catch (e) {
      print("Error in _pickAndUploadImage: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء رفع الصورة")),
      );
    }
  }

  Widget _buildQuestionForm(int index) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'السؤال',
              prefixIcon: IconButton(
                icon: Icon(Icons.image),
                onPressed: () => _pickAndUploadImage(index),
              ),
            ),
            onChanged: (value) => _questions[index]['question'] = value,
          ),
          if (_questions[index]['imageUrl'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.network(
                _questions[index]['imageUrl'],
                height: 150,
              ),
            ),
          ...List.generate(
            4,
            (optionIndex) => TextFormField(
              decoration:
                  InputDecoration(labelText: 'الاختيار ${optionIndex + 1}'),
              onChanged: (value) =>
                  _questions[index]['options'][optionIndex] = value,
            ),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'رقم الإجابة الصحيحة (1-4)'),
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                _questions[index]['correctAnswer'] = int.parse(value) - 1,
          ),
        ],
      ),
    );
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
}
