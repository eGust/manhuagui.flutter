import 'package:flutter/material.dart';

const TEST_URL = 'https://i.hamreus.com/ps1/g/GrandBlue/%E7%AC%AC19%E5%9B%9E/03.jpg.webp?cid=199830&md5=tt2xffnmOLvq8k_RumWz_g';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Container(
      child:
        // Image.network(
        //     TEST_URL,
        //     headers: { 'Referer': 'https://m.manhuagui.com' },
        //   ),
        Text(
          'test ttt',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: Colors.blueAccent.shade700,
            fontSize: 20.0
          ),
        ),
      alignment: Alignment.center,
      color: Colors.yellow.shade700,
    );
}
