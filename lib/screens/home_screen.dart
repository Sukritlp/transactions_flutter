import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final String userId = 'your_user_id'; // เปลี่ยนเป็น userId ของผู้ใช้

  @override
  Widget build(BuildContext context) {
    // ดึงขนาดของหน้าจอจาก MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final double iconSize = screenSize.width * 0.15;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'My Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: Icon(Icons.person), // ไอคอนเป็นรูปคน
                onPressed: () {
                  // นำทางไปยังหน้าข้อมูลผู้ใช้
                  Navigator.pushNamed(context, '/author_information');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.05,
                ), // ช่องว่างตามหน้าจอ

                // ดึงข้อมูลยอดเงินคงเหลือจาก Firestore
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator(); // แสดงวงกลมโหลดข้อมูล
                    }

                    // ดึงยอดเงินคงเหลือจาก Firestore
                    double totalBalance =
                        snapshot.data!.get('totalBalance') ?? 0.0;

                    return Center(
                      child: AspectRatio(
                        aspectRatio: 1, // กำหนดสัดส่วนให้เป็น 1:1
                        child: Container(
                          width: constraints.maxWidth *
                              0.6, // ปรับขนาดวงกลมตามขนาดหน้าจอ
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.teal, width: 6),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ยอดเงินที่ใช้ได้',
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: constraints.maxHeight * 0.01),
                                Text(
                                  '${totalBalance.toStringAsFixed(2)} ฿', // แสดงยอดเงินจริงจาก Firestore
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.1,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(
                    height: constraints.maxHeight * 0.05), // ช่องว่างตามหน้าจอ

                // ไอคอนเมนูการใช้งาน
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // ให้เลื่อนในแนวนอน
                    child: Row(
                      children: [
                        _buildMenuItemWithNavigation(Icons.pie_chart,
                            'รายงานการเงิน', context, iconSize),
                        _buildMenuItemWithNavigation(
                            Icons.money, 'เพิ่มรายการ', context, iconSize),
                        _buildMenuItemWithNavigation(
                            Icons.receipt, 'Statement', context, iconSize),
                        _buildMenuItemWithNavigation(
                            Icons.shopping_bag, 'Add Goal', context, iconSize),
                        _buildMenuItemWithNavigation(
                            Icons.pie_chart, 'My Goals', context, iconSize),
                        _buildMenuItemWithNavigation(Icons.attach_money,
                            'Budget Setup', context, iconSize),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ฟังก์ชันสร้างเมนูไอคอนพร้อมการลิงก์ไปหน้าอื่น
  Widget _buildMenuItemWithNavigation(
      IconData icon, String label, BuildContext context, double iconSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8.0), // เว้นระยะห่างระหว่างไอคอน
      child: InkWell(
        onTap: () {
          if (label == 'รายงานการเงิน') {
            Navigator.pushNamed(context, '/monthly-report');
          } else if (label == 'เพิ่มรายการ') {
            Navigator.pushNamed(context, '/add-transaction');
          } else if (label == 'Statement') {
            Navigator.pushNamed(context, '/transactions');
          } else if (label == 'Add Goal') {
            Navigator.pushNamed(context, '/add-savings-goal');
          } else if (label == 'My Goals') {
            Navigator.pushNamed(context, '/savings-goals');
          } else if (label == 'Budget Setup') {
            Navigator.pushNamed(context, '/budget-setup');
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: iconSize / 2,
              backgroundColor: Colors.grey.shade200,
              child: Icon(icon, size: iconSize, color: Colors.teal),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: iconSize * 0.3,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
