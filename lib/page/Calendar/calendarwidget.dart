import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(245, 245, 245, 1),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month selector with navigation arrows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/arrowleft_icon.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color.fromRGBO(30, 32, 30, 1),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    '03/2025',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/arrowright_icon.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          // Calendar container
          Container(
            margin: const EdgeInsets.only(top: 19),
            padding: const EdgeInsets.only(bottom: 30),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Days of week header
                Container(
                  color: const Color.fromRGBO(60, 61, 55, 1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('T2',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white,
                          )),
                      Text('T3',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white,
                          )),
                      Text('T4',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white,
                          )),
                      Text('T5',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white,
                          )),
                      Text('T6',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white,
                          )),
                      Text('T7',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white,
                          )),
                      Text('CN',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),

                // First row of dates (1-2)
                Container(
                  margin: const EdgeInsets.only(right: 34),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text('1',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      SizedBox(width: 41),
                      Text('2',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                    ],
                  ),
                ),

                // Second row of dates (3-9)
                Container(
                  margin: const EdgeInsets.only(top: 33),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('3',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('4',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('5',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('6',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('7',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('8',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('9',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                    ],
                  ),
                ),

                // Third row of dates (10-16)
                Container(
                  margin: const EdgeInsets.only(top: 33),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('10',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('11',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('12',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('13',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('14',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('15',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                      Text('16',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color.fromRGBO(60, 61, 55, 1),
                          )),
                    ],
                  ),
                ),

                // Fourth row with dates and amounts (17-23)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('17',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Color.fromRGBO(60, 61, 55, 1),
                                  )),
                              SizedBox(width: 20),
                              Text('18',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Color.fromRGBO(60, 61, 55, 1),
                                  )),
                              SizedBox(width: 20),
                              Text('19',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Color.fromRGBO(60, 61, 55, 1),
                                  )),
                              SizedBox(width: 20),
                              Text('20',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Color.fromRGBO(60, 61, 55, 1),
                                  )),
                              SizedBox(width: 20),
                              Text('21',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Color.fromRGBO(60, 61, 55, 1),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 17),
                          const Text(
                            '1,000,000',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10,
                              color: Color.fromRGBO(74, 189, 87, 1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 31),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '240,000',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10,
                              color: Color.fromRGBO(254, 0, 9, 1),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: const [
                              Text('22',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Color.fromRGBO(60, 61, 55, 1),
                                  )),
                              SizedBox(width: 20),
                              Text('23',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Color.fromRGBO(60, 61, 55, 1),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '500,000',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10,
                              color: Color.fromRGBO(254, 0, 9, 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Fifth row of dates (24-30)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Expanded(
                            child: Text('24',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Color.fromRGBO(60, 61, 55, 1),
                                )),
                          ),
                          Text('25',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color.fromRGBO(60, 61, 55, 1),
                              )),
                          SizedBox(width: 29),
                          Text('26',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color.fromRGBO(60, 61, 55, 1),
                              )),
                          SizedBox(width: 29),
                          Text('27',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color.fromRGBO(60, 61, 55, 1),
                              )),
                          SizedBox(width: 29),
                          Text('28',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color.fromRGBO(60, 61, 55, 1),
                              )),
                          SizedBox(width: 29),
                          Text('29',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color.fromRGBO(60, 61, 55, 1),
                              )),
                          SizedBox(width: 29),
                          Text('30',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color.fromRGBO(60, 61, 55, 1),
                              )),
                        ],
                      ),
                      const SizedBox(height: 33),
                      const Text(
                        '31',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Color.fromRGBO(60, 61, 55, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Summary section
          Container(
            margin: const EdgeInsets.only(top: 11),
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Income column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Thu nhập',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '1,000,000 đ',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Color.fromRGBO(74, 189, 87, 1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expense column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Chi Tiêu',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '740,000 đ',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Color.fromRGBO(254, 0, 0, 1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Total column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tổng',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Color.fromRGBO(0, 0, 0, 1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '+360,000 đ',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transaction list
          // First transaction date
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: const Color.fromRGBO(105, 117, 101, 1),
            width: double.infinity,
            child: const Text(
              '01/03/2025 (Thứ 7)',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),

          // First transaction
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/food.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Ăn uống',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                  ],
                ),
                const Text(
                  '-240,000 đ',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: Color.fromRGBO(254, 0, 0, 1),
                  ),
                ),
              ],
            ),
          ),

          // Second transaction date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: const Color.fromRGBO(105, 117, 101, 1),
            width: double.infinity,
            child: const Text(
              '03/03/2025 (Thứ 2)',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),

          // Second transaction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/cate29.png',
                      width: 35,
                      height: 35,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Tiền lương',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                  ],
                ),
                const Text(
                  '+1,000,000 đ',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: Color.fromRGBO(74, 189, 87, 1),
                  ),
                ),
              ],
            ),
          ),

          // Third transaction date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: const Color.fromRGBO(105, 117, 101, 1),
            width: double.infinity,
            child: const Text(
              '08/03/2025 (Thứ 7)',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),

          // Third transaction
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/mypham.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Mỹ phẩm',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                  ],
                ),
                const Text(
                  '-500,000 đ',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: Color.fromRGBO(254, 0, 0, 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

