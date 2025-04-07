import 'package:flutter/material.dart';
import 'package:flutter_moneymate_01/widgets/menuitem/settings_item.dart';
import '../../../widgets/custom_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CaiDat extends StatelessWidget {
  const CaiDat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
         title: Text(
          "Cài đặt",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showToggleButtons: false,
        showMenuButton: true, // Hiển thị nút menu (Drawer)
        onMenuPressed: () {
          Scaffold.of(context).openDrawer(); // Mở drawer từ MainPage
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display Section
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.0.w, 30.0.h, 16.0.w, 0.0.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Text(
                                  'Hiển thị',
                                  style: TextStyle(
                                    fontFamily:
                                        'Montserrat', // Sử dụng font Montserrat đã thêm
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Column(
                                  children: [
                                    SettingsItem(
                                      title: 'Thay đổi ngôn ngữ',
                                      value: 'Tiếng Việt',
                                      icon:
                                          'assets/images/arrow2_icon.png', // Đường dẫn đến biểu tượng
                                      hasBorder: true,
                                    ),
                                    SettingsItem(
                                      title: 'Thay đổi tiền tệ',
                                      value: 'VND',
                                      icon:
                                          'assets/images/arrow2_icon.png', // Đường dẫn đến biểu tượng
                                      hasBorder: true,
                                    ),
                                    SettingsItem(
                                      title: 'Thay đổi chủ đề',
                                      value: 'Sáng',
                                      icon:
                                          'assets/images/arrow2_icon.png', // Đường dẫn đến biểu tượng
                                      hasBorder: false,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Data Section
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.0.w, 30.0.h, 16.0.w, 0.0.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Text(
                                  'Dữ liệu',
                                  style: TextStyle(
                                    fontFamily:
                                        'Montserrat', // Sử dụng font Montserrat đã thêm
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                padding:
                                    EdgeInsets.symmetric(horizontal: 13.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Xoá tất cả dữ liệu',
                                      style: TextStyle(
                                        fontFamily:
                                            'Montserrat', // Sử dụng font Montserrat đã thêm
                                        fontSize: 15.sp,
                                        color: Color(0xFFFE0000),
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/images/delete_icon.png', // Đường dẫn đến biểu tượng xóa
                                      width: 25.w,
                                      height: 25.h,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
