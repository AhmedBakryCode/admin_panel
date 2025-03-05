import 'package:flutter/material.dart';
import 'courses_screen.dart';
import 'tests_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الرئيسية')),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildGridItem(context, 'الكورسات', Icons.video_library, CoursesScreen()),
          _buildGridItem(context, 'الاختبارات', Icons.quiz, TestsScreen()),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}