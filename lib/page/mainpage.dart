import 'package:flutter/material.dart';
import 'package:flutter_moneymate_01/page/menu/caidat_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/themkhoanthuchi_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/chitieu/danhmucchi_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/chitieu/themdanhmucchi_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/thunhap/danhmucthu_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/thunhap/themdanhmucthu_screen.dart';
import 'package:flutter_moneymate_01/page/baoCao/reportwidget.dart';
import 'package:flutter_moneymate_01/page/dashboard/dashboardwidget.dart';
import 'package:flutter_moneymate_01/page/dashboard/lichsughichep_screen.dart';
import 'package:flutter_moneymate_01/page/dashboard/lichsutheodanhmuc_screen.dart';
import 'package:flutter_moneymate_01/page/User/userwidget.dart';
import 'package:flutter_moneymate_01/page/Calendar/calendarwidget.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_moneymate_01/page/menu/thongbao_screen.dart';
import 'package:flutter_moneymate_01/page/menu/vitien_screen.dart';
import 'authentication/login/dangnhap_screen.dart';
import 'baoCao/timkiembaocao_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class Mainpage extends StatefulWidget {
  //const Mainpage({Key? key}) : super(key: key);
  final int selectedIndex;
  final String? categoryId; // Thêm tham số cho LichSuTheoDanhMuc
  final bool? isIncome; // Thêm tham số cho LichSuTheoDanhMuc
  final String? selectedMonth; // Thêm tham số cho LichSuTheoDanhMuc

  const Mainpage({
    Key? key,
    this.selectedIndex = 0,
    this.categoryId,
    this.isIncome,
    this.selectedMonth,
  }) : super(key: key);

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;

    // Nếu index là 9 và có tham số, điều hướng trực tiếp đến LichSuTheoDanhMuc
    if (_selectedIndex == 9 &&
        widget.categoryId != null &&
        widget.isIncome != null &&
        widget.selectedMonth != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LichSuTheoDanhMuc(
              categoryId: widget.categoryId!,
              isIncome: widget.isIncome!,
              selectedMonth: widget.selectedMonth!,
            ),
          ),
        );
      });
    }
  }

  static TextStyle optionStyle =
      TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold);
  // Khởi tạo _widgetOptions mà không truyền callback trực tiếp
  late List<Widget> _widgetOptions;

  // Hàm để tạo widget ThemKhoanThuChi với callback
  Widget _buildThemKhoanThuChi() {
    return ThemKhoanThuChi(
      onTransactionSaved: (index) {
        setState(() {
          _selectedIndex = index; // Quay lại Dashboard (index 0)
        });
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Khởi tạo _widgetOptions trong didChangeDependencies
    _widgetOptions = <Widget>[
      DashboardWidget(),
      CalendarWidget(),
      _buildThemKhoanThuChi(), // Sử dụng hàm để tạo ThemKhoanThuChi
      ReportWidget(),
      UserWidget(),
      ThongBao(),
      ViTien(),
      CaiDat(),
      LichSuGhiChep(),
      const SizedBox(),
      DanhMucChi(),
      DanhMucThu(),
      ThemDanhMucChi(),
      TimKiemBaoCaoThuChi(),
      ThemDanhMucThu(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Hàm lấy thông tin người dùng từ Firestore
  Future<Map<String, dynamic>?> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();
      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data();
      }
    }
    return null;
  }

  // Hàm đăng xuất khỏi Firebase Authentication
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Đăng xuất khỏi Firebase
      print('Đã đăng xuất thành công');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DangNhap()),
      );
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng xuất: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu index là 9 nhưng không có tham số, hiển thị thông báo lỗi hoặc quay lại Dashboard
    if (_selectedIndex == 9 &&
        (widget.categoryId == null ||
            widget.isIncome == null ||
            widget.selectedMonth == null)) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Không thể hiển thị lịch sử theo danh mục mà không có dữ liệu.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey, // Key để mở Drawer từ trang con
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(0
              .w), // Tất cả padding = 0 và sẽ responsive theo chiều rộng màn hình
          children: [
            // DrawerHeader với dữ liệu từ Firestore
            FutureBuilder<Map<String, dynamic>?>(
              future: _fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Hiển thị loading khi đang tải dữ liệu
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF1E201E)),
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  // Hiển thị mặc định nếu có lỗi hoặc không có dữ liệu
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF1E201E)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40.r,
                          backgroundColor:
                              Colors.white, // Hình tròn trắng nếu lỗi
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Không xác định',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                        Text(
                          'Không có email',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Dữ liệu từ Firestore
                  var userData = snapshot.data!;
                  String image = userData['image'] ?? '';
                  String username = userData['username'] ?? 'Không xác định';
                  String email = userData['email'] ?? 'Không có email';

                  return Container(
                    height: 250.h, // Điều chỉnh chiều cao ở đây
                    child: DrawerHeader(
                      decoration: BoxDecoration(color: Color(0xFF1E201E)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50
                                .r, // Tăng giá trị radius để hình tròn lớn hơn
                            backgroundColor:
                                image.isEmpty ? Colors.white : null,
                            backgroundImage: image.isNotEmpty
                                ? (image.startsWith('assets/')
                                    ? AssetImage(
                                        image) // For local asset images
                                    : (image.startsWith(
                                            'http') // Check if the image is a network image
                                        ? NetworkImage(
                                            image) // For network images
                                        : FileImage(
                                            File(image)))) // For file images
                                : null,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            username,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.sp),
                          ),
                          Text(
                            email,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.sp),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            // Các mục menu trong Drawer
            ListTile(
              leading: const Icon(Icons.notifications_on_outlined),
              title: const Text('Thông báo'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 5;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Ví của tôi'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 6;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_suggest_outlined),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 7;
                });
              },
            ),
            const Divider(color: Colors.black),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Đăng xuất'),
              onTap: _logout, // Gọi hàm đăng xuất
            ),
          ],
        ),
      ),
      bottomNavigationBar: StyleProvider(
        style: Style(),
        child: ConvexAppBar(
          backgroundColor: const Color(0xFF1E201E),
          activeColor: Colors.white,
          color: Colors.white70,
          style: TabStyle.fixedCircle,
          height: 55.h,
          curveSize: 80.sp,
          top: -20.h,
          items: [
            TabItem(icon: Icons.home, title: 'Trang chủ'),
            TabItem(icon: Icons.calendar_month_outlined, title: 'Lịch'),
            TabItem(icon: Icons.add),
            TabItem(icon: Icons.pie_chart_rounded, title: 'Báo cáo'),
            TabItem(icon: Icons.people, title: 'Tài khoản'),
          ],
          onTap: (index) {
            setState(() {
              if (index < 5) {
                _selectedIndex = index;
              }
            });
          },
        ),
      ),
    );
  }
}

class Style extends StyleHook {
  @override
  double get activeIconSize => 40;

  @override
  double get activeIconMargin => 10;

  @override
  double get iconSize => 20;

  // Update this method to match the correct signature
  @override
  TextStyle textStyle(Color color, String? title) {
    return TextStyle(
      fontSize: color == Colors.blue
          ? 16.sp
          : 12.sp, // Use the color parameter to decide the font size
      color: color, // Use the color parameter here
    );
  }
}
