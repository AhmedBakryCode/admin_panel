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
      appBar: AppBar(title: Text(courseName!)),
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
              itemBuilder: (context, index) {
                final file = state.files[index];

                return ListTile(
                  title: Text(file.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(context, file),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFile(context, file),
                      ),
                      IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () => _downloadFile(file),
                      ),
                    ],
                  ),
                );
              },
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
      allowMultiple: false,
    );

    if (result == null) return;

    PlatformFile file = result.files.first;
    Uint8List? fileBytes = file.bytes ?? await File(file.path!).readAsBytes();
    if (fileBytes == null) return;

    String fileName = file.name;
    TextEditingController nameController =
    TextEditingController(text: fileName);

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
      await context.read<FilesCubit>().uploadFile(
        nameController.text,
        fileBytes,
      );
      // Show dialog to add test link after successful upload
      bool? addTestLink = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('إضافة رابط اختبار'),
          content: Text('هل تريد إضافة رابط اختبار لهذا الفيديو؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('لا'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('نعم'),
            ),
          ],
        ),
      );

      if (addTestLink == true) {
        TextEditingController linkController = TextEditingController();
        bool? linkConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('إدخال رابط الاختبار'),
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
                onPressed: () => Navigator.pop(context, false),
                child: Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  if (linkController.text.isNotEmpty) {
                    Navigator.pop(context, true);
                  }
                },
                child: Text('حفظ'),
              ),
            ],
          ),
        );

        if (linkConfirmed == true) {
          await context.read<FilesCubit>().addTestLink(
            nameController.text,
            linkController.text,
          );
        }
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context, Reference fileRef) async {
    TextEditingController nameController =
    TextEditingController(text: fileRef.name);
    Uint8List? newFileBytes;
    String? newFileName;

    Future<void> pickNewVideo() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        newFileName = result.files.first.name;
        newFileBytes = result.files.first.bytes ??
            await File(result.files.first.path!).readAsBytes();
      }
    }

    await showDialog(
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
                onPressed: () async {
                  await pickNewVideo();
                  setState(() {});
                },
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
                context
                    .read<FilesCubit>()
                    .editFileName(fileRef, nameController.text);
                Navigator.pop(context);
              },
              child: Text('✅ Finish'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteFile(BuildContext context, Reference fileRef) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الفيديو'),
        content: Text('هل أنت متأكد من حذف هذا الفيديو؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      context.read<FilesCubit>().deleteFile(fileRef);
    }
  }

  Future<void> _downloadFile(Reference fileRef) async {
    String url = await fileRef.getDownloadURL();
    print('رابط التحميل: $url');
  }
}