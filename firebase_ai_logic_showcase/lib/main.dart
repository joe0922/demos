import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const SorobanSchoolApp());
}

class SorobanSchoolApp extends StatelessWidget {
  const SorobanSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '生徒管理システム',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StudentListScreen(),
    );
  }
}

// 生徒一覧画面
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生徒管理（そろばん・プログラミング）'),
        backgroundColor: Colors.deepPurple.shade50,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('データの読み込みに失敗しました'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('登録されている生徒がいません。\n右下の「+」から登録してください。'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              final String name = data['name'] ?? '名前なし';
              final String grade = data['grade'] ?? '未設定';
              final String school = data['school'] ?? '未設定';
              
              // そろばん情報の取得
              final String abacusRank = data['abacusRank'] ?? '級位なし';
              final String mentalRank = data['mentalRank'] ?? '級位なし';
              final String association = data['association'] ?? '日珠連';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(name.isNotEmpty ? name[0] : '?'),
                  ),
                  title: Text('$name （$grade・$school）', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('そろばん: $association $abacusRank / 暗算: $mentalRank'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Text('🎂 生年月日: ${data['birthDate'] ?? '未設定'}'),
                          const SizedBox(height: 4),
                          Text('🏠 住所: ${data['address'] ?? '未設定'}'),
                          const SizedBox(height: 4),
                          Text('📞 保護者連絡先: ${data['parentContact'] ?? '未設定'}'),
                          const SizedBox(height: 8),
                          const Text('🏆 取得履歴:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(' ・珠算: $abacusRank (${data['abacusDate'] ?? '取得日未登録'})'),
                          Text(' ・暗算: $mentalRank (${data['mentalDate'] ?? '取得日未登録'})'),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddStudentDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 生徒追加ポップアップ画面
  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();
    final schoolController = TextEditingController();
    final birthController = TextEditingController();
    final addressController = TextEditingController();
    final parentController = TextEditingController();
    
    String association = '日珠連';
    final abacusRankController = TextEditingController();
    final abacusDateController = TextEditingController();
    final mentalRankController = TextEditingController();
    final mentalDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新入生・生徒の登録'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: '生徒氏名')),
                TextField(controller: gradeController, decoration: const InputDecoration(labelText: '学年 (例: 小3)')),
                TextField(controller: schoolController, decoration: const InputDecoration(labelText: '学校名')),
                TextField(controller: birthController, decoration: const InputDecoration(labelText: '生年月日 (例: 2017/05/10)')),
                TextField(controller: parentController, decoration: const InputDecoration(labelText: '保護者連絡先')),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: '住所')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: association,
                  decoration: const InputDecoration(labelText: '所属連盟'),
                  items: ['日珠連', '全珠連'].map((String val) {
                    return DropdownMenuItem<String>(value: val, child: Text(val));
                  }).toList(),
                  onChanged: (val) { if (val != null) association = val; },
                ),
                TextField(controller: abacusRankController, decoration: const InputDecoration(labelText: '珠算の級・段位')),
                TextField(controller: abacusDateController, decoration: const InputDecoration(labelText: '珠算の取得日')),
                TextField(controller: mentalRankController, decoration: const InputDecoration(labelText: '暗算の級・段位')),
                TextField(controller: mentalDateController, decoration: const InputDecoration(labelText: '暗算の取得日')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  // Firestoreへデータを自動保存
                  await FirebaseFirestore.instance.collection('students').add({
                    'name': nameController.text,
                    'grade': gradeController.text,
                    'school': schoolController.text,
                    'birthDate': birthController.text,
                    'parentContact': parentController.text,
                    'address': addressController.text,
                    'association': association,
                    'abacusRank': abacusRankController.text,
                    'abacusDate': abacusDateController.text,
                    'mentalRank': mentalRankController.text,
                    'mentalDate': mentalDateController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('登録'),
            ),
          ],
        );
      },
    );
  }
}
