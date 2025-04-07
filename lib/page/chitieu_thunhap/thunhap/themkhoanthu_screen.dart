import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/cateitem/category_item.dart';
import '../../../widgets/input/money_input.dart';
import 'danhmucthu_screen.dart';
import '../chitieu/themkhoanchi_screen.dart';
import '../../mainpage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class ThemKhoanThu extends StatefulWidget {
  const ThemKhoanThu({Key? key}) : super(key: key);

  @override
  State<ThemKhoanThu> createState() => _ThemKhoanThuState();
}

class _ThemKhoanThuState extends State<ThemKhoanThu> {
  int selectedCategoryIndex = -1;
  String _selectedWallet = 'Chọn ví tiền của bạn';
  DateTime? selectedDate;
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 5, now.month, now.day),
      lastDate: DateTime(now.year + 10, now.month, now.day),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _loadCategories() async {
    List<Map<String, dynamic>> categories = await _loadIncomeCategories();
    setState(() {
      _categories = categories;
      if (selectedCategoryIndex >= _categories.length) {
        selectedCategoryIndex = -1;
      }
    });
  }

  Future<List<Map<String, dynamic>>> _loadIncomeCategories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String userDocId = userDoc.docs.first.id;
        QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocId)
            .collection('danh_muc_thu')
            .get();

        return categorySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['ten_muc_thu'] as String,
            'image': doc['image'] as String,
          };
        }).toList();
      }
    }
    return [];
  }

  Future<void> _saveIncome() async {
    if (selectedDate == null ||
        _amountController.text.isEmpty ||
        _selectedWallet == 'Chọn ví tiền của bạn' ||
        selectedCategoryIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String userDocId = userDoc.docs.first.id;
        String categoryId = _categories[selectedCategoryIndex]['id'];

        String walletId = _selectedWallet == "Tiền mặt" ? "QXf9f0y54ga0CH3VFym0" : "X0dMqKhCQguVdmKRSOon";

        String cleanedAmount = _amountController.text.replaceAll(RegExp(r'[.,]'), '');
        double amount = double.parse(cleanedAmount);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocId)
            .collection('thu_nhap')
            .add({
          'ghi_chu': _noteController.text,
          'loai_vi': walletId,
          'muc_thu_nhap': categoryId,
          'ngay': DateFormat('yyyy-MM-dd').format(selectedDate!),
          'so_tien': amount,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu khoản thu')),
        );

        setState(() {
          selectedDate = null;
          _amountController.clear();
          _noteController.clear();
          _selectedWallet = 'Chọn ví tiền của bạn';
          selectedCategoryIndex = -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0x1A000000), width: 1)),
                      ),
                      constraints: BoxConstraints(minHeight: 78),
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Row(
                          children: [
                            Image.asset('assets/images/calendar_icon.png', width: 30, height: 30, fit: BoxFit.contain),
                            const SizedBox(width: 10),
                            const Text('Ngày', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Montserrat')),
                            const SizedBox(width: 40),
                            Container(width: 1, height: 40, color: const Color(0x331E201E)),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                selectedDate == null ? 'Chọn ngày tháng năm' : dateFormat.format(selectedDate!),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  color: selectedDate == null ? const Color(0x331E201E) : Colors.black,
                                ),
                              ),
                            ),
                            Image.asset('assets/images/arrow2_icon.png', width: 20, height: 20, fit: BoxFit.contain),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0x1A000000), width: 1)),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/images/money_icon.png', width: 30, height: 30, fit: BoxFit.contain),
                          const SizedBox(width: 7),
                          const Text('Số tiền', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Montserrat')),
                          const SizedBox(width: 25),
                          Container(width: 1, height: 40, color: const Color(0x331E201E)),
                          const SizedBox(width: 18),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, MoneyInputFormatter()],
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, fontFamily: 'Montserrat', color: Colors.black),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Nhập vào số tiền',
                                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, fontFamily: 'Montserrat', color: Color(0x331E201E)),
                              ),
                            ),
                          ),
                          const Text('đ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, fontFamily: 'Montserrat')),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 15, 72, 15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0x1A000000), width: 1)),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/images/note_icon.png', width: 30, height: 40, fit: BoxFit.contain),
                          const SizedBox(width: 7),
                          const Text('Ghi chú', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Montserrat')),
                          const SizedBox(width: 17),
                          Container(width: 1, height: 40, color: const Color(0x331E201E)),
                          const SizedBox(width: 18),
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, fontFamily: 'Montserrat', color: Colors.black),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Nhập vào ghi chú',
                                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, fontFamily: 'Montserrat', color: Color(0x331E201E)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Mục hay dùng', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Montserrat')),
                              const SizedBox(width: 7),
                              Image.asset('assets/images/dropdown_icon.png', width: 20, height: 20, fit: BoxFit.contain),
                            ],
                          ),
                          Transform.translate(
                            offset: const Offset(0, 0),
                            child: Container(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: _categories.isEmpty
                                  ? const Center(child: Text('Không có danh mục thu'))
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                      ),
                                      itemCount: _categories.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < _categories.length) {
                                          var category = _categories[index];
                                          return CategoryItem(
                                            imageUrl: category['image'],
                                            label: category['name'],
                                            isSelected: selectedCategoryIndex == index,
                                            onTap: () {
                                              setState(() {
                                                selectedCategoryIndex = index;
                                              });
                                            },
                                          );
                                        } else {
                                          return GestureDetector(
                                            onTap: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const DanhMucThu()),
                                              );
                                              if (result == true) {
                                                await _loadCategories();
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.edit, size: 30),
                                                  SizedBox(height: 5),
                                                  Text('Chỉnh sửa', style: TextStyle(fontSize: 15, fontFamily: 'Montserrat')),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0x1A000000), width: 1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/images/wallet_icon.png', width: 30, height: 30, fit: BoxFit.contain),
                              const SizedBox(width: 10),
                              const Text('Ví tiền', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Montserrat')),
                              const SizedBox(width: 30),
                              Container(width: 1, height: 40, color: const Color(0x331E201E)),
                              const SizedBox(width: 18),
                            ],
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                String? selectedWallet = await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      backgroundColor: Colors.white,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        width: 320,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 10, spreadRadius: 5)],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Center(
                                              child: Text(
                                                "Chọn ví tiền",
                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E4A59)),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            ListTile(
                                              leading: Image.asset('assets/images/cate30.png', width: 30, height: 30),
                                              title: const Text("Tiền mặt"),
                                              trailing: _selectedWallet == "Tiền mặt" ? const Icon(Icons.check, color: Colors.green) : null,
                                              onTap: () => Navigator.pop(context, "Tiền mặt"),
                                            ),
                                            ListTile(
                                              leading: Image.asset('assets/images/cate29.png', width: 30, height: 30),
                                              title: const Text("Chuyển khoản"),
                                              trailing: _selectedWallet == "Chuyển khoản" ? const Icon(Icons.check, color: Colors.green) : null,
                                              onTap: () => Navigator.pop(context, "Chuyển khoản"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                if (selectedWallet != null) {
                                  setState(() {
                                    _selectedWallet = selectedWallet;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  _selectedWallet,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                    color: _selectedWallet == 'Chọn ví tiền của bạn' ? const Color(0x331E201E) : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Image.asset('assets/images/arrow2_icon.png', width: 20, height: 20, fit: BoxFit.contain),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 30),
                      child: ElevatedButton(
                        onPressed: _saveIncome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E201E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 12),
                          minimumSize: const Size(220, 0),
                        ),
                        child: const Text(
                          'Lưu khoản thu',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'Montserrat'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}