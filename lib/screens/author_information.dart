import 'package:flutter/material.dart';

class AuthorInformation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Personal Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: constraints.maxWidth * 0.06,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black26,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.teal,
            elevation: 10,
          ),
          body: Container(
            color: Colors.grey[100],
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // จัดให้อยู่ตรงกลางในแนวตั้ง
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // จัดให้อยู่ตรงกลางในแนวนอน
                      children: [
                        // การ์ดข้อมูลสำหรับ Person 1
                        _buildPersonCard(
                          'Person 1',
                          [
                            _buildInfoText(
                                'First Name', 'Tanasap', constraints),
                            _buildInfoText(
                                'Last Name', 'Songsawang', constraints),
                            _buildInfoText('Student Number', '9', constraints),
                            _buildInfoText(
                                'Student Code', '6521600486', constraints),
                          ],
                          constraints,
                        ),
                        SizedBox(height: 30),
                        // การ์ดข้อมูลสำหรับ Person 2
                        _buildPersonCard(
                          'Person 2',
                          [
                            _buildInfoText('First Name', 'Sukrit', constraints),
                            _buildInfoText('Last Name', 'Lekphet', constraints),
                            _buildInfoText('Student Number', '41', constraints),
                            _buildInfoText(
                                'Student Code', '6521604317', constraints),
                          ],
                          constraints,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ฟังก์ชันสร้าง Card สำหรับกลุ่มข้อมูลของแต่ละคน
  Widget _buildPersonCard(
      String title, List<Widget> infoWidgets, BoxConstraints constraints) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // จัดให้อยู่ตรงกลางใน Card
          children: [
            _buildSectionTitle(title, constraints),
            ...infoWidgets,
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างชื่อส่วน พร้อมการตกแต่งใหม่
  Widget _buildSectionTitle(String title, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        // จัดให้อยู่ตรงกลาง
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: constraints.maxWidth * 0.05,
            color: Colors.teal,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black26,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างเนื้อหาข้อมูล พร้อมการตกแต่งใหม่
  Widget _buildInfoText(
      String label, String value, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // จัดให้อยู่ตรงกลางใน Card
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: constraints.maxWidth * 0.04,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: constraints.maxWidth * 0.05,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
