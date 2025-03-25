import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // สำหรับใช้ inputFormatters

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>(); // กุญแจสำหรับ Form
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedTransactionType = 'income'; // ค่าเริ่มต้นเป็นรายรับ
  String _selectedCategory = ''; // หมวดหมู่ที่เลือก
  DateTime _selectedDate = DateTime.now(); // วันที่เริ่มต้นเป็นวันนี้
  String _userId = 'your_user_id'; // เปลี่ยนเป็น userId จริงของคุณ

  // หมวดหมู่สำหรับรายจ่าย
  final List<String> _expenseCategories = [
    'อาหาร',
    'เดินทาง',
    'ที่พัก',
    'ของใช้',
    'บริการ',
    'ถูกยืม',
    'ค่ารักษา',
    'สัตว์เลี้ยง',
    'บริจาค',
    'การศึกษา',
    'คนรัก',
    'เสื้อผ้า',
    'เครื่องสำอาง',
    'เครื่องประดับ',
    'บันเทิง',
    'โทรศัพท์',
    'ครอบครัว',
    'ยานพาหนะ',
    'อื่นๆ'
  ];

  // หมวดหมู่สำหรับรายรับ
  final List<String> _incomeCategories = [
    'ได้รับเงินคืน',
    'ได้พิเศษ',
    'รายได้',
    'ได้ฟรี',
    'รายได้ธุรกิจ',
    'ยืมมา',
    'เงินปันผล',
    'อื่นๆ'
  ];

  // ฟังก์ชัน validate ให้กรอกเฉพาะตัวเลขและทศนิยม
  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกจำนวนเงิน';
    }

    final n = num.tryParse(value);
    if (n == null) {
      return 'กรุณากรอกเฉพาะตัวเลขหรือทศนิยม';
    }

    if (n <= 0) {
      return 'จำนวนเงินต้องมากกว่า 0';
    }

    return null;
  }

  // ฟังก์ชันเลือกวันที่
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  // ฟังก์ชันบันทึกธุรกรรมและอัปเดตยอดเงิน
  Future<void> _addTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return; // ถ้าตรวจสอบไม่ผ่าน ให้หยุด
    }

    final String amountText = _amountController.text.trim();
    final String description = _descriptionController.text.trim();
    final double amount = double.parse(amountText);

    // บันทึกธุรกรรมลง Firestore
    await FirebaseFirestore.instance.collection('transactions').add({
      'amount': amount,
      'category': _selectedCategory,
      'date': Timestamp.fromDate(_selectedDate),
      'description': description,
      'type': _selectedTransactionType,
      'userId': _userId,
      'notification': true,
    });

    // อัปเดตยอดเงินและหมวดหมู่การใช้จ่าย
    await _updateTotalBalance(amount);
    if (_selectedTransactionType == 'expense') {
      await _updateCategorySpent(amount);
    }

    _showSuccessPopup();
  }

  Future<void> _updateTotalBalance(double amount) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .get();

    if (userDoc.exists) {
      double currentBalance = userDoc['totalBalance'] ?? 0.0;

      if (_selectedTransactionType == 'income') {
        currentBalance += amount; // ถ้าเป็นรายรับให้บวกยอดเงิน
      } else {
        currentBalance -= amount; // ถ้าเป็นรายจ่ายให้หักยอดเงิน
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .update({'totalBalance': currentBalance});
    }
  }

   Future<void> _updateCategorySpent(double amount) async {
    // การอัปเดตข้อมูลการใช้จ่ายของหมวดหมู่
    DocumentSnapshot budgetDoc = await FirebaseFirestore.instance
        .collection('budget')
        .doc(_selectedCategory)
        .get();

    if (budgetDoc.exists) {
      double currentSpent = budgetDoc['spent'] ?? 0.0;
      await FirebaseFirestore.instance
          .collection('budget')
          .doc(_selectedCategory)
          .update({'spent': currentSpent + amount});
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('สำเร็จ'),
        content: Text('เพิ่มรายการสำเร็จ!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: screenSize.width * 0.06),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Amount', _amountController,
                      TextInputType.number, _validateAmount),
                  SizedBox(height: screenSize.height * 0.02),
                  _buildTextField('Description', _descriptionController,
                      TextInputType.text, null),
                  SizedBox(height: screenSize.height * 0.02),
                  _buildDropdown('Transaction Type', ['income', 'expense'],
                      _selectedTransactionType, (newValue) {
                    setState(() {
                      _selectedTransactionType = newValue!;
                      _selectedCategory = '';
                    });
                  }),
                  SizedBox(height: screenSize.height * 0.02),
                  _buildDropdown(
                      'Category',
                      _selectedTransactionType == 'income'
                          ? _incomeCategories
                          : _expenseCategories,
                      _selectedCategory, (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  }),
                  SizedBox(height: screenSize.height * 0.02),
                  _buildDateSelector(screenSize),
                  SizedBox(height: screenSize.height * 0.03),
                  Center(
                    child: ElevatedButton(
                      onPressed: _addTransaction,
                      child: Text('Add Transaction',
                          style:
                              TextStyle(fontSize: screenSize.width * 0.045)),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.2,
                            vertical: screenSize.height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ฟังก์ชันช่วยสร้าง TextField
  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType keyboardType, String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2), // กรอบสีแดงเมื่อกรอกผิด
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2), // กรอบสีแดงเมื่อโฟกัสและกรอกผิด
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: [
        if (keyboardType == TextInputType.number)
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,2}$'), // ยอมรับเฉพาะตัวเลขและทศนิยม
          ),
      ],
      validator: validator, // ใช้ฟังก์ชันตรวจสอบข้อมูล
    );
  }

  // ฟังก์ชันสร้าง DropdownButton
  Widget _buildDropdown(String label, List<String> items, String selectedValue,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        DropdownButton<String>(
          value: selectedValue.isEmpty ? null : selectedValue,
          hint: Text('เลือก $label'),
          isExpanded: true,
          items: items.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ฟังก์ชันเลือกวันที่
  Widget _buildDateSelector(Size screenSize) {
    return Row(
      children: [
        Flexible(
          child: Text(
            'Selected date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
            style: TextStyle(fontSize: screenSize.width * 0.04),
            overflow: TextOverflow.ellipsis, // ตัดข้อความถ้ายาวเกินไป
          ),
        ),
        SizedBox(width: screenSize.width * 0.02),
        Flexible(
          child: TextButton(
            onPressed: _presentDatePicker,
            child: Text(
              'Choose Date',
              style: TextStyle(
                  color: Colors.teal, fontSize: screenSize.width * 0.04),
            ),
          ),
        ),
      ],
    );
  }
}
