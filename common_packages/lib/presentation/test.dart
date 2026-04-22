// packages/common_packages/lib/presentation/test_firestore_button.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestFirestoreButton extends StatelessWidget {
  const TestFirestoreButton({super.key});

  Future<void> _testConnection(BuildContext context) async {
    try {
      // Ghi 1 document test
      await FirebaseFirestore.instance
          .collection('test_connection')
          .doc('status')
          .set({
        'message': 'Kết nối Firestore thành công!',
        'timestamp': FieldValue.serverTimestamp(),
        'environment': const String.fromEnvironment('DART_DEFINE_ENV', defaultValue: 'unknown'),
      });

      // Đọc lại để xác nhận
      final doc = await FirebaseFirestore.instance
          .collection('test_connection')
          .doc('status')
          .get();

      if (doc.exists) {
        final data = doc.data();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Firestore OK!\nEnv: ${data?['environment'] ?? 'unknown'}\nTime: ${data?['timestamp'] ?? 'N/A'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Lỗi Firestore: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _testConnection(context),
      icon: const Icon(Icons.cloud_queue),
      label: const Text('Test Firestore'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}