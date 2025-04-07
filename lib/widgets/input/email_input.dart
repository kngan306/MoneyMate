import 'package:flutter/material.dart';

class EmailInput extends StatefulWidget {
  final TextEditingController controller; // Thêm biến controller

  const EmailInput({Key? key, required this.controller}) : super(key: key); // Nhận controller từ bên ngoài

  @override
  _EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.07),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF1E201E),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/email_icon.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              Container(
                width: 1,
                height: 35,
                color: const Color.fromRGBO(30, 32, 30, 0.1),
              ),
              const SizedBox(width: 14),
            ],
          ),
          Expanded(
            child: TextField(
              controller: widget.controller, // Sử dụng controller từ widget
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: 'moneymate@gmail.com',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.black,
              size: 22,
            ),
            onPressed: () {
              widget.controller.clear(); // Xóa nội dung của controller
            },
          ),
        ],
      ),
    );
  }
}