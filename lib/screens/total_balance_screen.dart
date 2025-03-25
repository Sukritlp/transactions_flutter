import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalBalanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Balance'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('transactions').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          double totalBalance = 0;

          // คำนวณยอดรวมจาก income และ expense
          snapshot.data!.docs.forEach((doc) {
            if (doc['type'] == 'income') {
              totalBalance += doc['amount'];
            } else if (doc['type'] == 'expense') {
              totalBalance -= doc['amount'];
            }
          });

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  totalBalance.toStringAsFixed(2), // แสดงยอดเงินทั้งหมด
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
