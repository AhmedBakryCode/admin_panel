import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/users_cubit.dart';

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة الحسابات')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddUserDialog(context),
      ),
      body: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) {
          if (state is UsersLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            return _buildUsersList(context, state.users);
          } else if (state is UsersError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('اضغط + لإضافة حساب جديد'));
        },
      ),
    );
  }

  Widget _buildUsersList(
      BuildContext context, List<Map<String, dynamic>> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(users[index]['name']),
        subtitle: Text(
            'مستخدم: ${users[index]['isUsed'] ? 'مُستخدم' : 'غير مُستخدم'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showEditUserDialog(context, users[index]),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, users[index]['id']),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة حساب جديد'),
        content: TextFormField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'اسم المستخدم'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<UsersCubit>().addUser(nameController.text);
                Navigator.pop(context);
              }
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    TextEditingController nameController =
        TextEditingController(text: user['name']);
    bool isUsed = user['isUsed'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تعديل الحساب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'اسم المستخدم'),
              ),
              CheckboxListTile(
                title: Text('حالة الاستخدام'),
                value: isUsed,
                onChanged: (value) => setState(() => isUsed = value!),
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
                context.read<UsersCubit>().updateUser(
                      user['id'],
                      nameController.text,
                      isUsed,
                    );
                Navigator.pop(context);
              },
              child: Text('حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الحساب'),
        content: Text('هل أنت متأكد من حذف هذا الحساب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('تراجع'),
          ),
          TextButton(
            onPressed: () {
              context.read<UsersCubit>().deleteUser(userId);
              Navigator.pop(context);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
