import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 📌 Import để hỗ trợ đa ngôn ngữ
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'page/splash/splash_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await initializeDateFormatting('vi_VN', null); // 🇻🇳 Khởi tạo ngôn ngữ tiếng Việt
  Intl.defaultLocale = 'vi_VN'; // Đặt mặc định là tiếng Việt

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 754), // Kích thước thiết kế gốc
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Montserrat', // Áp dụng font Montserrat cho toàn bộ app
          ),
          supportedLocales: const [
            Locale('vi', 'VN'), // 🇻🇳 Thêm hỗ trợ tiếng Việt
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: SplashScreen(),
        );
      },
    );
  }
}
