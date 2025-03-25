import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // ใช้สำหรับการจัดรูปแบบวันที่

class TransactionsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions List',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .orderBy('date', descending: true) // เรียงลำดับจากรายการล่าสุด
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              bool isIncome = doc['type'] == 'income';
              Color transactionColor = isIncome ? Colors.green : Colors.red;

              // แปลงข้อมูลวันที่จาก Firestore
              Timestamp timestamp = doc['date'];
              DateTime dateTime = timestamp.toDate();
              String formattedDate =
                  DateFormat('dd MMM yyyy, HH:mm').format(dateTime);

              return AnimatedContainer(
                duration: Duration(milliseconds: 300), // เพิ่มแอนิเมชั่น
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: transactionColor,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 3), // เงาเล็กน้อย
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    doc['category'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transactionColor,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount: ${doc['amount']} ฿ - ${doc['description']}',
                        style: TextStyle(
                          color: transactionColor,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Date: $formattedDate',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: transactionColor,
                    size: 30,
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
