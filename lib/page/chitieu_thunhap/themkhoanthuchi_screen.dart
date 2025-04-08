import 'package:flutter/material.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/chitieu/themkhoanchi_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/thunhap/themkhoanthu_screen.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/tab/thuchi_tab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemKhoanThuChi extends StatefulWidget {
  final Function(int)? onTransactionSaved; // Callback để thông báo khi lưu giao dịch

  ThemKhoanThuChi({this.onTransactionSaved});
  @override
  _ThemKhoanThuChiState createState() => _ThemKhoanThuChiState();
}

class _ThemKhoanThuChiState extends State<ThemKhoanThuChi> {
  bool isChiTieuSelected = true; // Mặc định là Chi tiêu

  void _onToggle(int index) {
    setState(() {
      isChiTieuSelected = index == 0;
    });
  }

  void _onTransactionSaved() {
    // Gọi callback để thông báo cho Mainpage rằng giao dịch đã được lưu
    if (widget.onTransactionSaved != null) {
      widget.onTransactionSaved!(0); // Quay lại Dashboard (index 0)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
         title: Text(
          "Thêm khoản thu chi",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        showToggleButtons: true,
        showMenuButton: true, // Hiển thị nút menu (Drawer)
        onMenuPressed: () {
          Scaffold.of(context).openDrawer(); // Mở drawer từ MainPage
        },
        selectedIndex: isChiTieuSelected ? 0 : 1,
        onToggle: _onToggle, // Chuyển tab khi nhấn trên AppBar
      ),
      body: Column(
        children: [
          // Thanh chọn tab
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     ThuchiTab(
          //       label: 'Chi tiêu',
          //       isSelected: isChiTieuSelected,
          //       onTap: () {
          //         setState(() {
          //           isChiTieuSelected = true;
          //         });
          //       },
          //     ),
          //     const SizedBox(width: 6),
          //     ThuchiTab(
          //       label: 'Thu nhập',
          //       isSelected: !isChiTieuSelected,
          //       onTap: () {
          //         setState(() {
          //           isChiTieuSelected = false;
          //         });
          //       },
          //     ),
          //   ],
          // ),
          Expanded(
            //child: isChiTieuSelected ? ThemKhoanChi() : ThemKhoanThu(),
            child: isChiTieuSelected
                ? ThemKhoanChi(onTransactionSaved: _onTransactionSaved)
                : ThemKhoanThu(onTransactionSaved: _onTransactionSaved),
          ),
        ],
      ),
    );
  }
}
