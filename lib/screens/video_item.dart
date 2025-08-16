import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/files_cubit.dart';

class VideoItem extends StatefulWidget {
  final String videoName;
  final Function(String, Uint8List?) onEdit;
  final Function(String) onDelete;
  final String courseName;

  const VideoItem({
    required this.videoName,
    required this.onEdit,
    required this.onDelete,
    required this.courseName,
    Key? key,
  }) : super(key: key);

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  String? newFileName;
  Uint8List? newFileBytes;
  bool hasTestLink = false;

  @override
  void initState() {
    super.initState();
    _checkTestLink();
  }

  Future<void> _checkTestLink() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tests_links')
        .where('courseName', isEqualTo: widget.courseName)
        .where('videoName', isEqualTo: widget.videoName)
        .get();
    if (mounted) {
      setState(() {
        hasTestLink = querySnapshot.docs.isNotEmpty;
      });
    }
  }

  void _pickNewVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        newFileName = result.files.first.name;
        newFileBytes = result.files.first.bytes;
      });
    }
  }

  void _showEditDialog() {
    TextEditingController nameController =
    TextEditingController(text: widget.videoName);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تعديل الفيديو'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'اسم الفيديو'),
              ),
              SizedBox(height: 10),
              newFileBytes == null
                  ? Text('📌 لم يتم اختيار فيديو جديد')
                  : Text('✅ فيديو جديد جاهز للرفع'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickNewVideo,
                child: Text('🔄 تغيير الفيديو'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onEdit(nameController.text, newFileBytes);
                Navigator.pop(context);
              },
              child: Text('✅ Finish'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTestDialog() {
    TextEditingController linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة رابط اختبار'),
        content: TextFormField(
          controller: linkController,
          decoration: InputDecoration(hintText: 'أدخل رابط جوجل فورم'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رابط';
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (linkController.text.isNotEmpty) {
                context.read<FilesCubit>().addTestLink(
                  widget.videoName,
                  linkController.text,
                );
                Navigator.pop(context);
                setState(() {
                  hasTestLink = true;
                });
              }
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.videoName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => widget.onDelete(widget.videoName),
          ),
          IconButton(
            icon: Icon(
              hasTestLink ? Icons.link : Icons.add_link,
              color: hasTestLink ? Colors.green : Colors.grey,
            ),
            onPressed: _showAddTestDialog,
          ),
        ],
      ),
    );
  }
}