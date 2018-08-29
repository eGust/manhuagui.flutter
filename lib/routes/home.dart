import 'package:flutter/material.dart';

const TEST_URL = 'https://i.hamreus.com/ps1/g/GrandBlue/%E7%AC%AC19%E5%9B%9E/03.jpg.webp?cid=199830&md5=tt2xffnmOLvq8k_RumWz_g';

Widget labelledIconButton({ String label, IconData icon }) =>
  Container(
    child: FlatButton(
      onPressed: () {},
      padding: const EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 16.0),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
            size: 40.0,
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    ),
    margin: const EdgeInsets.only(top: 6.0, bottom: 6.0),
  );

class Home extends StatelessWidget {
  static const SIDE_BAR_WIDTH = 80.0;
  @override
  Widget build(BuildContext context) =>
  Material(
    child: Container(
      child: Row(
        children: <Widget>[
          // Image.network(
          //     TEST_URL,
          //     headers: { 'Referer': 'https://m.manhuagui.com' },
          //   ),
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      labelledIconButton(
                        icon: Icons.home,
                        label: '首页',
                      ),
                      labelledIconButton(
                        icon: Icons.update,
                        label: '最近更新',
                      ),
                      labelledIconButton(
                        icon: Icons.category,
                        label: '漫画大全',
                      ),
                      labelledIconButton(
                        icon: Icons.insert_chart,
                        label: '排行榜',
                      ),
                      labelledIconButton(
                        icon: Icons.person,
                        label: '漫画家',
                      ),
                      labelledIconButton(
                        icon: Icons.favorite,
                        label: '我的收藏',
                      ),
                      labelledIconButton(
                        icon: Icons.history,
                        label: '最近阅读',
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  padding: const EdgeInsets.only(top: 100.0, bottom: 60.0),
                ),
                labelledIconButton(
                  icon: Icons.settings,
                  label: '账号管理',
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            width: SIDE_BAR_WIDTH,
            color: Colors.brown[800],
            alignment: Alignment.center,
          ),
          Container(
            child: Text(
              'def',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: Colors.blueAccent.shade700,
                fontSize: 20.0
              ),
            ),
            color: Colors.yellow[800],
            width: MediaQuery.of(context).size.width - SIDE_BAR_WIDTH,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
      ),
      padding: const EdgeInsets.only(top: 20.0),
      color: Colors.brown[800],
    ),
  );
}
