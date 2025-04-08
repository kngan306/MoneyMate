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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:diacritic/diacritic.dart'; // Thêm thư viện để xử lý dấu tiếng Việt

class ThemKhoanThu extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  final Function? onTransactionSaved; // Callback để thông báo khi lưu giao dịch

  const ThemKhoanThu({Key? key, this.transaction, this.onTransactionSaved})
      : super(key: key);
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
  String? userDocId;
  String? cashWalletId; // ID ví "Tiền mặt"
  String? transferWalletId; // ID ví "Chuyển khoản"

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Đồng bộ hóa các tác vụ bất đồng bộ
  Future<void> _initializeData() async {
    // Đầu tiên, tải dữ liệu người dùng và ví
    await _loadUserData();

    // Sau khi có userDocId, tải danh mục và ví (nếu đang chỉnh sửa giao dịch)
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      selectedDate = DateTime.parse(transaction['date']);
      _amountController.text =
          NumberFormat.currency(locale: 'vi_VN', symbol: '')
              .format(transaction['amount']);
      _noteController.text = transaction['note'];

      // Tải tên ví từ walletId
      if (transaction['walletId'] != null) {
        await _loadWalletName(transaction['walletId']);
      }

      // Tải danh mục và chọn danh mục tương ứng
      await _loadCategories();
      for (int i = 0; i < _categories.length; i++) {
        if (_categories[i]['id'] == transaction['categoryId']) {
          setState(() {
            selectedCategoryIndex = i;
          });
          break;
        }
      }
    } else {
      // Nếu thêm mới, chỉ cần tải danh mục
      await _loadCategories();
    }
  }

  // Tải dữ liệu người dùng và ví
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        userDocId = userDoc.docs.first.id;
        await _loadWalletIds(userDocId!);
        setState(() {}); // Cập nhật UI sau khi có userDocId
      }
    }
  }

  // Tải ID ví từ Firestore
  Future<void> _loadWalletIds(String userDocId) async {
    QuerySnapshot walletSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('vi_tien')
        .get();

    for (var doc in walletSnapshot.docs) {
      String walletName = doc['ten_vi'] as String;
      String normalizedWalletName = removeDiacritics(walletName).toLowerCase();
      if (normalizedWalletName == removeDiacritics('Tiền mặt').toLowerCase()) {
        cashWalletId = doc.id;
      } else if (normalizedWalletName ==
          removeDiacritics('Chuyển khoản').toLowerCase()) {
        transferWalletId = doc.id;
      }
    }
  }

  // Tải tên ví từ ID ví
  Future<void> _loadWalletName(String walletId) async {
    if (userDocId == null) return;
    try {
      DocumentSnapshot walletDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDocId)
          .collection('vi_tien')
          .doc(walletId)
          .get();

      if (walletDoc.exists) {
        String walletName = walletDoc['ten_vi'] as String;
        setState(() {
          _selectedWallet = walletName;
        });
      } else {
        // Nếu không tìm thấy ví, đặt lại giá trị mặc định
        setState(() {
          _selectedWallet = 'Chọn ví tiền của bạn';
        });
        print('Wallet with ID $walletId not found.');
      }
    } catch (e) {
      print('Error loading wallet name: $e');
      setState(() {
        _selectedWallet = 'Chọn ví tiền của bạn';
      });
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
        String? walletId =
            _selectedWallet == "Tiền mặt" ? cashWalletId : transferWalletId;

        if (walletId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy ví tương ứng')),
          );
          return;
        }
        String cleanedAmount =
            _amountController.text.replaceAll(RegExp(r'[.,]'), '');
        double amount = double.parse(cleanedAmount);

        if (widget.transaction != null) {
          // Cập nhật giao dịch
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocId)
              .collection('thu_nhap')
              .doc(widget.transaction!['id'])
              .update({
            'ghi_chu': _noteController.text,
            'loai_vi': walletId,
            'muc_thu_nhap': categoryId,
            'ngay': DateFormat('yyyy-MM-dd').format(selectedDate!),
            'so_tien': amount,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã cập nhật khoản thu')),
          );
        } else {
          // Thêm mới giao dịch
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
        }

        // Reset form sau khi lưu hoặc cập nhật
        setState(() {
          selectedDate = null;
          _amountController.clear();
          _noteController.clear();
          _selectedWallet = 'Chọn ví tiền của bạn';
          selectedCategoryIndex = -1;
        });

        // Gọi callback để thông báo rằng giao dịch đã được lưu
        if (widget.onTransactionSaved != null) {
          widget.onTransactionSaved!();
        }
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
                          Container(
                            height: 195, // Chiều cao cố định
                            padding: const EdgeInsets.only(top: 10.0),
                            child: _categories.isEmpty
                                ? const Center(
                                    child: Text('Không có danh mục chi'))
                                : GridView.builder(
                                    // shrinkWrap: false là mặc định, giữ nguyên hoặc bỏ cũng được
                                    physics:
                                        const BouncingScrollPhysics(), // Cho phép cuộn mềm mại
                                    itemCount: _categories.length + 1,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      mainAxisExtent: 90,
                                    ),
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
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Mainpage(
                                                  selectedIndex: 11,
                                                ),
                                              ),
                                            );
                                            if (result == true) {
                                              await _loadCategories();
                                              if (selectedCategoryIndex >=
                                                  _categories.length) {
                                                setState(() {
                                                  selectedCategoryIndex = -1;
                                                });
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                6.w, 30.h, 1.w, 30.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15.r),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Chỉnh sửa',
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                                SizedBox(width: 3.w),
                                                Image.asset(
                                                  'assets/images/arrow2_icon.png',
                                                  width: 20.w,
                                                  height: 20.h,
                                                  fit: BoxFit.contain,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                          )
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
                                              title: Text(
                                                "Tiền mặt",
                                                style:
                                                    TextStyle(fontSize: 15.sp),
                                              ),
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
                                              title: Text(
                                                "Chuyển khoản",
                                                style:
                                                    TextStyle(fontSize: 15.sp),
                                              ),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                        onPressed: _saveIncome,
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
                              ? 'Cập nhật khoản thu'
                              : 'Lưu khoản thu',
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
