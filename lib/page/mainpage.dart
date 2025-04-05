import 'package:flutter/material.dart';
import 'package:flutter_moneymate_01/page/menu/caidat_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/themkhoanthuchi_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/chitieu/danhmucchi_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/thunhap/danhmucthu_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/themdanhmucthuchi_screen.dart';
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

class Mainpage extends StatefulWidget {
  //const Mainpage({Key? key}) : super(key: key);
  final int selectedIndex;
  const Mainpage({Key? key, this.selectedIndex = 0}) : super(key: key);

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
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    DashboardWidget(),
    CalendarWidget(),
    ThemKhoanThuChi(),
    ReportWidget(),
    UserWidget(),
    ThongBao(), //5
    ViTien(), //6
    CaiDat(), //7
    LichSuGhiChep(), //8
    LichSuTheoDanhMuc(), //9
    DanhMucChi(), //10
    DanhMucThu(), //11
    ThemDanhMucThuChi(), //12
    TimKiemBaoCaoThuChi(), //13
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  // // Danh sách tiêu đề ứng với từng màn hình
  // static final List<String> _titles = [
  //   "Trang chủ",
  //   "Lịch",
  //   "Thêm khoản thu chi",
  //   "Báo cáo",
  //   "Tài khoản",
  //   "Thông báo", //5
  //   "Ví của tôi", //6
  //   "Cài đặt", //7
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: const Color(0xFF1E201E),
      //   title: Text(
      //     _titles[_selectedIndex], // Tiêu đề động theo từng màn hình
      //     style: const TextStyle(
      //       color: Colors.white,
      //       fontFamily: 'Montserrat', // Đặt font chữ
      //       fontSize: 20, // Kích thước chữ
      //       fontWeight: FontWeight.bold, // Làm đậm chữ nếu cần
      //     ),
      //   ),
      //   centerTitle: true, // Căn giữa tiêu đề
      //   leading: Builder(
      //     builder: (context) => IconButton(
      //       icon: const Icon(Icons.menu, color: Colors.white),
      //       onPressed: () {
      //         Scaffold.of(context).openDrawer();
      //       },
      //     ),
      //   ),
      // ),
      key: _scaffoldKey, // Key để mở Drawer từ trang con

      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E201E)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/avt.jpg'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Duy Kha',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '22dh111480@st.huflit.edu.vn',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
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
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DangNhap(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: const Color(0xFF1E201E),
        activeColor: Colors.white,
        color: Colors.white70,
        style: TabStyle.fixedCircle,
        height: 55,
        curveSize: 80,
        top: -20,
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
    );
  }
}
