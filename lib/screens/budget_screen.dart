import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _budgetController = TextEditingController();
  String _selectedCategory = ''; // หมวดหมู่ที่เลือก

  final List<String> _categories = [
    'อาหาร',
    'เดินทาง',
    'ที่พัก',
    'ของใช้',
    'บริการ',
    'ค่ารักษา',
    'สัตว์เลี้ยง',
    'บริจาค',
    'การศึกษา',
    'คนรัก',
    'เสื้อผ้า',
    'เครื่องสำอาง',
    'บันเทิง',
    'ยานพาหนะ',
    'อื่นๆ'
  ];

  // ฟังก์ชันสำหรับเพิ่มงบประมาณใน Firestore
  Future<void> _addBudget() async {
    if (_selectedCategory.isEmpty || _budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    double budgetAmount = double.parse(_budgetController.text);

    await FirebaseFirestore.instance
        .collection('budget')
        .doc(_selectedCategory)
        .set({
      'category': _selectedCategory,
      'amount': budgetAmount,
      'spent': 0.0, // ฟิลด์ spent เริ่มต้นที่ 0
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เพิ่มงบประมาณสำเร็จ')),
    );

    // เคลียร์ข้อมูลหลังจากเพิ่มงบประมาณ
    setState(() {
      _budgetController.clear();
      _selectedCategory = '';
    });
  }

  // ฟังก์ชันตรวจสอบการใช้จ่าย
  Future<void> _checkSpendingAlert(String category, double budgetAmount) async {
    double totalSpent = 0;

    QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('category', isEqualTo: category)
        .get();

    transactionsSnapshot.docs.forEach((doc) {
      totalSpent += doc['amount'];
    });

    if (totalSpent >= 0.8 * budgetAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ค่าใช้จ่ายใน $category ใกล้เกินงบแล้ว')),
      );
    }
  }

  // ฟังก์ชันคำนวณเปอร์เซ็นต์การใช้จ่าย
  double _calculateSpendingPercentage(double spent, double budget) {
    if (budget == 0) return 0.0;
    return spent / budget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตั้งงบประมาณ'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // ใส่ SingleChildScrollView รอบ Column
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // การเลือกหมวดหมู่และการกรอกงบประมาณ
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เลือกหมวดหมู่',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedCategory.isEmpty
                                  ? null
                                  : _selectedCategory,
                              hint: Text('เลือกหมวดหมู่'),
                              isExpanded: true,
                              items: _categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedCategory = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'จำนวนงบประมาณ (฿)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'กรอกจำนวนงบประมาณ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _addBudget();
                            _checkSpendingAlert(_selectedCategory,
                                double.parse(_budgetController.text));
                          },
                          child: Text('เพิ่มงบประมาณ'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // แสดงงบประมาณแต่ละหมวดหมู่
              StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('budget').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    shrinkWrap: true, // ให้ ListView ขนาดเล็กลงตามเนื้อหา
                    physics:
                        NeverScrollableScrollPhysics(), // ปิดการเลื่อนใน ListView
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      double amount = doc['amount'];
                      double spent = doc['spent'];

                      double progress = spent / amount;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['category'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation(
                                  progress >= 1.0 ? Colors.red : Colors.green,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'ใช้จ่ายไปแล้ว: ${spent.toStringAsFixed(2)} ฿ / งบประมาณ: ${amount.toStringAsFixed(2)} ฿',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
