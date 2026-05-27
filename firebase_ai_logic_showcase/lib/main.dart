import 'package:flutter/material.dart';

void main() {
  runApp(const StudentManagementApp());
}

class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '生徒管理システム',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StudentListScreen(),
    );
  }
}

// 生徒データの簡易モデル（後でFirestoreと連動させます）
class Student {
  final String name;
  final String course;
  final bool isPresent;

  Student({required this.name, required this.course, required this.isPresent});
}

// 生徒一覧画面（ここを起点に開発していきます）
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  // テスト用のダミーデータ
  final List<Student> students = [
    Student(name: '山田 太郎', course: 'Scratchコース', isPresent: true),
    Student(name: '佐藤 次郎', course: 'Pythonコース', isPresent: false),
    Student(name: '鈴木 花子', course: 'Web開発コース', isPresent: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生徒一覧（Make Programming）'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: ListView.builder(
        itemCount: students.length, // エラー回避のため便宜上。正しくは students.length です。後ほどAIが直します
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(student.name[0]),
            ),
            title: Text(student.name),
            subtitle: Text(student.course),
            trailing: Chip(
              label: Text(student.isPresent ? '出席' : '欠席'),
              backgroundColor: student.isPresent ? Colors.green.shade100 : Colors.red.shade100,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ここに生徒追加のアクションを後で書きます
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}