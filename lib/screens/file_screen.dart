import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../cubits/files_cubit.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final courseName = context.read<FilesCubit>().courseName;

    return Scaffold(
      appBar: AppBar(title: Text(courseName)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.upload),
        onPressed: () => _pickAndUploadVideo(context),
      ),
      body: BlocBuilder<FilesCubit, FilesState>(
        builder: (context, state) {
          if (state is FilesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is FilesLoaded) {
            return ListView.builder(
              itemCount: state.files.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(state.files[index].name),
                trailing: IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () => _downloadFile(state.files[index]),
                ),
              ),
            );
          } else if (state is FilesError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('اضغط + لرفع فيديو'));
        },
      ),
    );
  }

  Future<void> _pickAndUploadVideo(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (result == null) return;

    PlatformFile file = result.files.first;
    Uint8List? fileBytes = file.bytes;
    String fileName = file.name;

    if (fileBytes == null) return;

    TextEditingController nameController = TextEditingController(text: fileName);
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اسم الفيديو'),
        content: TextFormField(
          controller: nameController,
          decoration: InputDecoration(hintText: 'أدخل اسم الفيديو'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('رفع'),
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.isNotEmpty) {
      context.read<FilesCubit>().uploadFile(
            nameController.text,
            fileBytes,
          );
    }
  }

  Future<void> _downloadFile(Reference fileRef) async {
    String url = await fileRef.getDownloadURL();
    // يمكنك استخدام package مثل 'url_launcher' لفتح الرابط
    print('رابط التحميل: $url');
  }
}