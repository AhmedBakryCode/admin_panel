import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoItem extends StatefulWidget {
  final String videoName;
  final Function(String, String?) onEdit;
  final Function(String) onDelete;

  const VideoItem({
    required this.videoName,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  String? newFileName;
  Uint8List? newFileBytes;

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
                widget.onEdit(nameController.text, newFileBytes as String);
                Navigator.pop(context);
              },
              child: Text('✅ Finish'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.videoName),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: _showEditDialog,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => widget.onDelete(widget.videoName),
            ),
          ],
        ),
      ],
    );
  }
}
