import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // ใช้ในการจัดรูปแบบวันที่

class MonthlyReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monthly Financial Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal, // เปลี่ยนสี AppBar
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ดึงข้อมูลขนาดของหน้าจอจาก MediaQuery
          final screenSize = MediaQuery.of(context).size;
          final padding =
              screenSize.width * 0.05; // ใช้ขนาด padding ตามขนาดหน้าจอ

          return FutureBuilder(
            future: FirebaseFirestore.instance.collection('transactions').get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              // สร้างแผนที่สำหรับเก็บข้อมูลรายงานสรุปการเงินประจำเดือน
              Map<String, Map<String, double>> monthlySummary = {};

              snapshot.data!.docs.forEach((doc) {
                Timestamp timestamp = doc['date'];
                DateTime date = timestamp.toDate();
                String monthYear = DateFormat('MMM yyyy').format(date);

                String type =
                    doc['type']; // ประเภทของธุรกรรม (income หรือ expense)
                double amount = doc['amount']; // จำนวนเงินของธุรกรรม

                // ถ้าเดือนนี้ยังไม่มีในรายงานให้เพิ่มเข้าไป
                if (!monthlySummary.containsKey(monthYear)) {
                  monthlySummary[monthYear] = {
                    'income': 0.0,
                    'expense': 0.0,
                  };
                }

                // เพิ่มยอดเงินตามประเภทของธุรกรรม
                if (type == 'income') {
                  // ดึงค่าปัจจุบันมาแล้วบวกเพิ่ม
                  monthlySummary[monthYear]!['income'] =
                      (monthlySummary[monthYear]!['income'] ?? 0) + amount;
                } else if (type == 'expense') {
                  // ดึงค่าปัจจุบันมาแล้วบวกเพิ่ม
                  monthlySummary[monthYear]!['expense'] =
                      (monthlySummary[monthYear]!['expense'] ?? 0) + amount;
                }
              });

              // แสดงรายงานสรุปการเงินประจำเดือน
              return ListView(
                padding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: padding),
                children: monthlySummary.keys.map((monthYear) {
                  return Card(
                    elevation: 5, // เพิ่มเงาให้กับการ์ด
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // ปรับขอบการ์ดให้โค้งมน
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            monthYear,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width *
                                  0.05, // ปรับขนาดฟอนต์ตามหน้าจอ
                              color: Colors.teal, // ใช้สีหลักที่ทันสมัย
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTransactionText(
                                  'Income',
                                  '${monthlySummary[monthYear]!['income']!.toStringAsFixed(2)} ฿',
                                  Colors.green,
                                  screenSize),
                              _buildTransactionText(
                                  'Expense',
                                  '${monthlySummary[monthYear]!['expense']!.toStringAsFixed(2)} ฿',
                                  Colors.red,
                                  screenSize),
                            ],
                          ),
                          Divider(
                            color: Colors.grey.shade400,
                            thickness: 1,
                            height: screenSize.height * 0.02,
                          ),
                          Text(
                            'Net Balance: ${(monthlySummary[monthYear]!['income']! - monthlySummary[monthYear]!['expense']!).toStringAsFixed(2)} ฿',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  screenSize.width * 0.045, // ปรับขนาดฟอนต์
                              color: (monthlySummary[monthYear]!['income']! -
                                          monthlySummary[monthYear]![
                                              'expense']! >=
                                      0)
                                  ? Colors.green
                                  : Colors
                                      .red, // เปลี่ยนสีตามผลลัพธ์ว่าเป็นบวกหรือลบ
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  // ฟังก์ชันช่วยสร้างข้อความสรุปธุรกรรม
  Widget _buildTransactionText(
      String label, String amount, Color color, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: screenSize.width * 0.04, // ปรับขนาดฟอนต์ตามหน้าจอ
            color: Colors.black54,
          ),
        ),
        SizedBox(height: screenSize.height * 0.005),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenSize.width * 0.045, // ปรับขนาดฟอนต์ตามหน้าจอ
            color: color,
          ),
        ),
      ],
    );
  }
}
