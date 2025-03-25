import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  @override
  _AddSavingsGoalScreenState createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();

  void _addSavingsGoal() {
    final String goalName = _goalNameController.text;
    final double targetAmount = double.parse(_targetAmountController.text);

    // บันทึกเป้าหมายการออมลง Firestore
    FirebaseFirestore.instance.collection('savings_goals').add({
      'goalName': goalName,
      'targetAmount': targetAmount,
      'savedAmount': 0.0, // เริ่มต้นการออมจาก 0
      'createdAt': Timestamp.now(),
    });

    Navigator.of(context).pop(); // ปิดหน้าจอหลังจากบันทึกเป้าหมาย
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // ดึงขนาดหน้าจอ

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Savings Goal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenSize.width * 0.06, // ปรับขนาดตัวอักษรตามหน้าจอ
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        // ใช้ SingleChildScrollView เพื่อให้สามารถเลื่อนได้ถ้าเนื้อหาเกินหน้าจอ
        padding: EdgeInsets.all(
            screenSize.width * 0.05), // ปรับ padding ตามขนาดหน้าจอ
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a new savings goal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenSize.width * 0.05, // ปรับขนาดตัวอักษร
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: screenSize.height * 0.03), // ระยะห่างตามขนาดหน้าจอ
            TextField(
              controller: _goalNameController,
              decoration: InputDecoration(
                labelText: 'Goal Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal, width: 2),
                ),
                labelStyle: TextStyle(
                  color: Colors.teal,
                  fontSize: screenSize.width * 0.04, // ปรับขนาดตัวอักษร
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.03), // ระยะห่างตามขนาดหน้าจอ
            TextField(
              controller: _targetAmountController,
              decoration: InputDecoration(
                labelText: 'Target Amount (฿)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal, width: 2),
                ),
                labelStyle: TextStyle(
                  color: Colors.teal,
                  fontSize: screenSize.width * 0.04, // ปรับขนาดตัวอักษร
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: screenSize.height * 0.05), // ระยะห่างตามขนาดหน้าจอ
            Center(
              child: ElevatedButton(
                onPressed: _addSavingsGoal,
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.2,
                    vertical: screenSize.height * 0.02,
                  ), // ปรับขนาดปุ่มตามหน้าจอ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Add Goal',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.045, // ปรับขนาดตัวอักษร
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
