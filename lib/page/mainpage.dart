import 'package:flutter/material.dart';
import 'package:flutter_moneymate_01/page/baoCao/reportwidget.dart';
import 'package:flutter_moneymate_01/page/dashboard/dashboardwidget.dart';
import 'package:flutter_moneymate_01/page/User/userwidget.dart';
import 'package:flutter_moneymate_01/page/Calendar/calendarwidget.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({Key? key}) : super(key: key);

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    //Để vào sau
    DashboardWidget(),
    CalendarWidget(),
    ReportWidget(),
    UserWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E201E), // Màu nền giống như hình
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Mở drawer khi nhấn icon menu
            },
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      drawer: Drawer(
        child: ListView(
          //Important: Remove any padding from the ListView
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                        'https://googleflutter.com/sample_image.jpg'),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text('Duy Kha'),
                  Text('22dh111480@st.huflit.edu.vn'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_on_outlined),
              title: const Text('Thông báo'),
              onTap: () {
                Navigator.pop(context);
                _selectedIndex = 0;
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Ví của tôi'),
              onTap: () {
                Navigator.pop(context);
                _selectedIndex = 1;
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_suggest_outlined),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.pop(context);
                _selectedIndex = 2;
                setState(() {});
              },
            ),
            const Divider(
              color: Colors.black,
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Đăng xuất'),
              onTap: () {
                Navigator.pop(context);
                _selectedIndex = 0;
                setState(() {});
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Lịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_rounded),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 11, 7, 233),
        onTap: _onItemTapped,
      ),
    ));
  }
}
