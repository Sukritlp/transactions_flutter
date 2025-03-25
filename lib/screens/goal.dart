import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoalsScreen extends StatelessWidget {
  final String _userId = 'your_user_id'; // userId ของผู้ใช้ (สามารถปรับได้)

  // ฟังก์ชันดึงยอดเงินทั้งหมดจาก transactions collection
  Future<double> _getTotalBalance() async {
    double totalBalance = 0;

    QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: _userId) // ดึงเฉพาะธุรกรรมของผู้ใช้
        .get();

    transactionsSnapshot.docs.forEach((doc) {
      if (doc['type'] == 'income') {
        totalBalance += doc['amount']; // บวกกับยอดรายรับ
      } else if (doc['type'] == 'expense') {
        totalBalance -= doc['amount']; // ลบกับยอดรายจ่าย
      }
    });

    return totalBalance;
  }

  // ฟังก์ชันเพิ่มเงินไปยังเป้าหมาย
  // ฟังก์ชันเพิ่มเงินไปยังเป้าหมาย
Future<void> _addMoneyToGoal(String goalId, double amount) async {
  try {
    // ดึงยอดเงินทั้งหมด
    double totalBalance = await _getTotalBalance();

    // ตรวจสอบว่าเงินพอหรือไม่
    if (amount > totalBalance) {
      throw Exception("ยอดเงินไม่เพียงพอ");
    }

    // ดึงข้อมูลเป้าหมายจาก Firestore
    DocumentSnapshot goalSnapshot = await FirebaseFirestore.instance
        .collection('savings_goals')
        .doc(goalId)
        .get();

    Map<String, dynamic> goalData =
        goalSnapshot.data() as Map<String, dynamic>;

    // ดึงยอดเงินปัจจุบันของเป้าหมาย
    double currentSavedAmount =
        goalData.containsKey('savedAmount') ? goalData['savedAmount'] : 0.0;

    // เพิ่มจำนวนเงินลงในเป้าหมาย
    double updatedAmount = currentSavedAmount + amount;

    // อัปเดตยอดเงินในเป้าหมาย
    await FirebaseFirestore.instance
        .collection('savings_goals')
        .doc(goalId)
        .update({
      'savedAmount': updatedAmount,
    });

    // อัปเดตยอดเงินคงเหลือใน transactions collection
    await FirebaseFirestore.instance.collection('transactions').add({
      'amount': amount,
      'category': 'Transfer to Goal',
      'date': Timestamp.now(),
      'description': 'Transfer to savings goal',
      'type': 'expense', // ถือว่าเป็นการใช้เงิน
      'userId': _userId,
    });

    // **อัปเดตยอดเงินคงเหลือของผู้ใช้ใน users collection**
    double newBalance = totalBalance - amount; // คำนวณยอดเงินใหม่
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .update({
      'totalBalance': newBalance, // อัปเดตยอดเงินใน users collection
    });

    print("Money added successfully and balance updated");
  } catch (e) {
    print('Error adding money to goal: $e');
    throw e;
  }
}


  // ฟังก์ชันแสดง Dialog เพื่อเพิ่มเงินไปยังเป้าหมาย
  void _showAddMoneyDialog(BuildContext context, String goalId) {
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('เพิ่มเงินไปยังเป้าหมาย'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount (฿)'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                double amount = double.parse(_amountController.text);
                await _addMoneyToGoal(
                    goalId, amount); // เรียกฟังก์ชันเพื่อเพิ่มเงิน
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('เพิ่มเงินสำเร็จ!'),
                ));
              } catch (e) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('เพิ่มเงินไม่สำเร็จ: ${e.toString()}'),
                ));
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันลบเป้าหมาย
  void _deleteGoal(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ลบเป้าหมาย'),
        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบเป้าหมายนี้?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // ลบเป้าหมายจาก Firestore
              await FirebaseFirestore.instance
                  .collection('savings_goals')
                  .doc(goalId)
                  .delete();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('ลบเป้าหมายสำเร็จ!'),
              ));
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแก้ไขเป้าหมาย
  void _showEditGoalDialog(BuildContext context, String goalId,
      String currentName, double targetAmount) {
    final TextEditingController _nameController =
        TextEditingController(text: currentName);
    final TextEditingController _targetAmountController =
        TextEditingController(text: targetAmount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('แก้ไขเป้าหมาย'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Goal Name'),
            ),
            TextField(
              controller: _targetAmountController,
              decoration: InputDecoration(labelText: 'Target Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String newName = _nameController.text;
              double newTargetAmount =
                  double.parse(_targetAmountController.text);

              // อัปเดตเป้าหมายใน Firestore
              await FirebaseFirestore.instance
                  .collection('savings_goals')
                  .doc(goalId)
                  .update({
                'goalName': newName,
                'targetAmount': newTargetAmount,
              });

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('แก้ไขเป้าหมายสำเร็จ!'),
              ));
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // ดึงขนาดหน้าจอ

    return Scaffold(
      appBar: AppBar(
        title: Text('My Savings Goals'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('savings_goals').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot goal = snapshot.data!.docs[index];

              double savedAmount = goal['savedAmount'] ?? 0.0;
              double targetAmount = goal['targetAmount'];
              double progressPercentage = savedAmount / targetAmount;

              return Card(
                margin: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.02,
                    horizontal: screenSize.width * 0.04),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['goalName'],
                        style: TextStyle(
                          fontSize: screenSize.width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(
                            progressPercentage >= 1 ? Colors.red : Colors.teal),
                      ),
                      SizedBox(height: screenSize.height * 0.005),
                      Text(
                        'Saved: ${savedAmount.toStringAsFixed(2)} ฿ / Target: ${targetAmount.toStringAsFixed(2)} ฿',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.035,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.teal,
                            onPressed: () {
                              _showEditGoalDialog(context, goal.id,
                                  goal['goalName'], goal['targetAmount']);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _deleteGoal(context, goal.id);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            color: Colors.teal,
                            onPressed: () {
                              _showAddMoneyDialog(context, goal.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
