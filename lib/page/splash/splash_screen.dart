import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chaomung_screen.dart';
import '../dashboard/dashboardwidget.dart';
import '../mainpage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    // Timer(Duration(seconds: 3), () {
    //   if (mounted) {
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => ChaoMung()),
    //     );
    //     // Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    //   }
    // });
  }

  void _checkLoginStatus() {
    Timer(Duration(seconds: 3), () {
      if (!mounted) return;

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Đã đăng nhập -> vào Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Mainpage(selectedIndex: 0),
          ),
        );
      } else {
        // Chưa đăng nhập -> vào Chào Mừng
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChaoMung()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECDFCC),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 85,
              height: 85,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 5),
            Text(
              'MoneyMate',
              style: TextStyle(
                color: const Color(0xFF3C3D37),
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Bạn đồng hành quản lý tiền bạc',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}