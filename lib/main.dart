import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'screens/add_transaction_screen.dart';
import 'screens/transactions_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/monthly_report_screen.dart';
import 'screens/add_savinggoal.dart';
import 'screens/goal.dart';
import 'screens/budget_screen.dart';
import 'screens/login.dart';
import 'screens/author_information.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // กำหนดค่า FirebaseOptions สำหรับ Android
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD3S0g0Fh7TuB8AjQLZiJ83YnEaaJudRfY",
      appId: "1:451211074149:android:98806be43997692219848c",
      messagingSenderId: "451211074149",
      projectId: "transactions-d35cb",
      storageBucket: "transactions-d35cb.appspot.com",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/auth', // ตั้งค่าให้หน้า Auth เป็นหน้าแรก
      routes: {
        '/auth': (context) => AuthScreen(), // หน้า Login/Register
        '/': (context) => HomeScreen(),
        '/add-transaction': (context) => AddTransactionScreen(),
        '/transactions': (context) => TransactionsListScreen(),
        '/monthly-report': (context) => MonthlyReportScreen(),
        '/add-savings-goal': (context) => AddSavingsGoalScreen(),
        '/savings-goals': (context) => SavingsGoalsScreen(),
        '/budget-setup': (context) => BudgetScreen(),
        '/author_information': (context) => AuthorInformation(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomeScreen(); // ส่งไปที่ Home ถ้าผู้ใช้ล็อกอินอยู่
        } else {
          return AuthScreen(); // ส่งไปที่หน้า Login ถ้าไม่ได้ล็อกอิน
        }
      },
    );
  }
}
