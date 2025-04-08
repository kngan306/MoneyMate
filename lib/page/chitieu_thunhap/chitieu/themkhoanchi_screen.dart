import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/cateitem/category_item.dart';
import '../../../widgets/input/money_input.dart';
import 'danhmucchi_screen.dart';
import '../thunhap/themkhoanthu_screen.dart';
import '../../mainpage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemKhoanChi extends StatefulWidget {
  final Map<String, dynamic>? transaction; // Thêm tham số transaction
  const ThemKhoanChi({Key? key, this.transaction}) : super(key: key);

  @override
  State<ThemKhoanChi> createState() => _ThemKhoanChiState();
}

class _ThemKhoanChiState extends State<ThemKhoanChi> {
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
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      selectedDate = DateTime.parse(transaction['date']);
      _amountController.text =
          NumberFormat.currency(locale: 'vi_VN', symbol: '')
              .format(transaction['amount']);
      _noteController.text = transaction['note'];
      _selectedWallet = transaction['walletId'] == "QXf9f0y54ga0CH3VFym0"
          ? "Tiền mặt"
          : "Chuyển khoản";
      _loadCategories().then((_) {
        for (int i = 0; i < _categories.length; i++) {
          if (_categories[i]['id'] == transaction['categoryId']) {
            setState(() {
              selectedCategoryIndex = i;
            });
            break;
          }
        }
      });
    } else {
      _loadCategories();
    }
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
    List<Map<String, dynamic>> categories = await _loadExpenseCategories();
    setState(() {
      _categories = categories;
      // Đặt lại selectedCategoryIndex nếu nó không còn hợp lệ
      if (selectedCategoryIndex >= _categories.length) {
        selectedCategoryIndex = -1;
      }
    });
  }

  Future<List<Map<String, dynamic>>> _loadExpenseCategories() async {
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
            .collection('danh_muc_chi')
            .get();

        return categorySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['ten_muc_chi'] as String,
            'image': doc['image'] as String,
          };
        }).toList();
      }
    }
    return [];
  }

  Future<void> _saveExpense() async {
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
        String walletId = _selectedWallet == "Tiền mặt"
            ? "QXf9f0y54ga0CH3VFym0"
            : "X0dMqKhCQguVdmKRSOon";
        String cleanedAmount =
            _amountController.text.replaceAll(RegExp(r'[.,]'), '');
        double amount = double.parse(cleanedAmount);

        if (widget.transaction != null) {
          // Cập nhật giao dịch
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocId)
              .collection('chi_tieu')
              .doc(widget.transaction!['id'])
              .update({
            'ghi_chu': _noteController.text,
            'loai_vi': walletId,
            'muc_chi_tieu': categoryId,
            'ngay': DateFormat('yyyy-MM-dd').format(selectedDate!),
            'so_tien': amount,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã cập nhật khoản chi')),
          );
        } else {
          // Thêm mới giao dịch
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocId)
              .collection('chi_tieu')
              .add({
            'ghi_chu': _noteController.text,
            'loai_vi': walletId,
            'muc_chi_tieu': categoryId,
            'ngay': DateFormat('yyyy-MM-dd').format(selectedDate!),
            'so_tien': amount,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã lưu khoản chi')),
          );
        }

        // Reset form sau khi lưu hoặc cập nhật
        setState(() {
          selectedDate = null;
          _amountController.clear();
          _noteController.clear();
          _selectedWallet = 'Chọn ví tiền của bạn';
          selectedCategoryIndex = -1;
        });

        // Trả về true để báo hiệu rằng giao dịch đã được cập nhật
        Navigator.pop(context, true);
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 13.w, vertical: 15.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(
                                color: Color(0x1A000000), width: 1.w)),
                      ),
                      constraints: BoxConstraints(minHeight: 78.h),
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Row(
                          children: [
                            Image.asset('assets/images/calendar_icon.png',
                                width: 30.w, height: 30.h, fit: BoxFit.contain),
                            SizedBox(width: 10.w),
                            Text('Ngày',
                                style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat')),
                            SizedBox(width: 40.w),
                            Container(
                                width: 1.w,
                                height: 40.h,
                                color: const Color(0x331E201E)),
                            SizedBox(width: 18.w),
                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? 'Chọn ngày tháng năm'
                                    : dateFormat.format(selectedDate!),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  color: selectedDate == null
                                      ? const Color(0x331E201E)
                                      : Colors.black,
                                ),
                              ),
                            ),
                            Image.asset('assets/images/arrow2_icon.png',
                                width: 20.w, height: 20.h, fit: BoxFit.contain),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 15.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(
                                color: Color(0x1A000000), width: 1.w)),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/images/money_icon.png',
                              width: 30.w, height: 30.h, fit: BoxFit.contain),
                          SizedBox(width: 7.w),
                          Text('Số tiền',
                              style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat')),
                          SizedBox(width: 25.w),
                          Container(
                              width: 1.w,
                              height: 40.h,
                              color: const Color(0x331E201E)),
                          SizedBox(width: 18.w),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                MoneyInputFormatter()
                              ],
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  color: Colors.black),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Nhập vào số tiền',
                                hintStyle: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                    color: Color(0x331E201E)),
                              ),
                            ),
                          ),
                          Text('đ',
                              style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat')),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(16.w, 15.h, 72.w, 15.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(
                                color: Color(0x1A000000), width: 1.w)),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/images/note_icon.png',
                              width: 30.w, height: 40.h, fit: BoxFit.contain),
                          SizedBox(width: 7.w),
                          Text('Ghi chú',
                              style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat')),
                          SizedBox(width: 17.w),
                          Container(
                              width: 1.w,
                              height: 40.h,
                              color: const Color(0x331E201E)),
                          SizedBox(width: 18.w),
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  color: Colors.black),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Nhập vào ghi chú',
                                hintStyle: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                    color: Color(0x331E201E)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Mục hay dùng',
                                  style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Montserrat')),
                              SizedBox(width: 7.w),
                              Image.asset('assets/images/dropdown_icon.png',
                                  width: 20.w,
                                  height: 20.h,
                                  fit: BoxFit.contain),
                            ],
                          ),
                          Transform.translate(
                            offset: const Offset(0, 0),
                            child: Container(
                              padding: EdgeInsets.only(top: 10.0),
                              child: _categories.isEmpty
                                  ? const Center(
                                      child: Text('Không có danh mục chi'))
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                            isSelected:
                                                selectedCategoryIndex == index,
                                            onTap: () {
                                              setState(() {
                                                selectedCategoryIndex = index;
                                              });
                                            },
                                          );
                                        } else {
                                          return GestureDetector(
                                            onTap: () async {
                                              // Chuyển đến màn hình DanhMucChi và chờ kết quả
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Mainpage(
                                                    selectedIndex: 10,
                                                  ),
                                                ),
                                              );
                                              // Nếu có thay đổi (thêm/xóa danh mục), tải lại danh sách
                                              if (result == true) {
                                                await _loadCategories();
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.edit, size: 30),
                                                  SizedBox(height: 5),
                                                  Text('Chỉnh sửa',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontFamily:
                                                              'Montserrat')),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 13.w, vertical: 15.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(
                                color: Color(0x1A000000), width: 1.w)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/images/wallet_icon.png',
                                  width: 30.w,
                                  height: 30.h,
                                  fit: BoxFit.contain),
                              SizedBox(width: 10.w),
                              Text('Ví tiền',
                                  style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Montserrat')),
                              SizedBox(width: 30.w),
                              Container(
                                  width: 1.w,
                                  height: 40.h,
                                  color: const Color(0x331E201E)),
                              SizedBox(width: 18.w),
                            ],
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                String? selectedWallet =
                                    await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      backgroundColor: Colors.white,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        width: 320,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color(0x10000000),
                                                blurRadius: 10,
                                                spreadRadius: 5)
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Center(
                                              child: Text(
                                                "Chọn ví tiền",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF3E4A59)),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            ListTile(
                                              leading: Image.asset(
                                                  'assets/images/cate30.png',
                                                  width: 30,
                                                  height: 30),
                                              title: const Text("Tiền mặt"),
                                              trailing:
                                                  _selectedWallet == "Tiền mặt"
                                                      ? const Icon(Icons.check,
                                                          color: Colors.green)
                                                      : null,
                                              onTap: () => Navigator.pop(
                                                  context, "Tiền mặt"),
                                            ),
                                            ListTile(
                                              leading: Image.asset(
                                                  'assets/images/cate29.png',
                                                  width: 30,
                                                  height: 30),
                                              title: const Text("Chuyển khoản"),
                                              trailing: _selectedWallet ==
                                                      "Chuyển khoản"
                                                  ? const Icon(Icons.check,
                                                      color: Colors.green)
                                                  : null,
                                              onTap: () => Navigator.pop(
                                                  context, "Chuyển khoản"),
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
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Text(
                                  _selectedWallet,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                    color: _selectedWallet ==
                                            'Chọn ví tiền của bạn'
                                        ? const Color(0x331E201E)
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Image.asset('assets/images/arrow2_icon.png',
                              width: 20.w, height: 20.h, fit: BoxFit.contain),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20.h, bottom: 30.h),
                      child: ElevatedButton(
                        onPressed: _saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E201E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 49.w, vertical: 12.h),
                          minimumSize: Size(220.w, 0),
                        ),
                        child: Text(
                          widget.transaction != null
                              ? 'Cập nhật khoản chi'
                              : 'Lưu khoản chi',
                          style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontFamily: 'Montserrat'),
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
