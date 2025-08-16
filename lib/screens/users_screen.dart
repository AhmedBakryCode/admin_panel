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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('كود: ${users[index]['code']}'),
            Text('الكورسات:'),
            ...users[index]['courses'].entries.map((entry) => Text(
                '${entry.key}: ${entry.value ? 'مُستخدم' : 'غير مُستخدم'}')),
          ],
        ),
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
    String? selectedCourse;

    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<String>>(
        future: context.read<UsersCubit>().getAvailableCourses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return AlertDialog(
              content: Text('خطأ في جلب الكورسات'),
            );
          }
          List<String> availableCourses = snapshot.data!;
          String code = context.read<UsersCubit>().generateUniqueCode();

          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text('إضافة حساب جديد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'اسم المستخدم'),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'اختر الكورس'),
                    value: selectedCourse,
                    items: availableCourses
                        .map((course) => DropdownMenuItem(
                              value: course,
                              child: Text(course),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedCourse = value),
                  ),
                  SizedBox(height: 16),
                  Text('الكود المُولد: $code'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        selectedCourse != null) {
                      Map<String, bool> courseUsage = {
                        for (var course in availableCourses)
                          course: course == selectedCourse
                      };
                      context.read<UsersCubit>().addUser(
                            nameController.text,
                            code,
                            courseUsage,
                          );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('يرجى إدخال الاسم واختيار كورس')),
                      );
                    }
                  },
                  child: Text('حفظ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    TextEditingController nameController =
        TextEditingController(text: user['name']);
    Map<String, bool> courseUsage = Map.from(user['courses']);

    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<String>>(
        future: context.read<UsersCubit>().getAvailableCourses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return AlertDialog(
              content: Text('خطأ في جلب الكورسات'),
            );
          }
          List<String> availableCourses = snapshot.data!;

          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text('تعديل الحساب'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'اسم المستخدم'),
                  ),
                  Text('الكود: ${user['code']}'),
                  ...availableCourses.map(
                    (course) => CheckboxListTile(
                      title: Text(course),
                      value: courseUsage[course] ?? false,
                      onChanged: (value) =>
                          setState(() => courseUsage[course] = value!),
                    ),
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
                          user['code'],
                          courseUsage,
                        );
                    Navigator.pop(context);
                  },
                  child: Text('حفظ التعديلات'),
                ),
              ],
            ),
          );
        },
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
