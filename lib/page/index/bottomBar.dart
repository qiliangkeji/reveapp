import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/page/index/account.dart';
import 'package:flutter_application_2/page/index/download.dart';
import 'package:flutter_application_2/page/index/index.dart';
import '../../util/SpUtils.dart';

/// 底部栏
class Bottom extends StatefulWidget {
  Bottom({super.key});

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  // 页面控制器
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          Index(),
          Download(),
          Account(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 95,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white70,
          elevation: 1,
          iconSize: 25,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_outlined, size: 27),
              label: "存储",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.download_for_offline_outlined, size: 27),
              label: "下载",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined, size: 27),
              label: "用户",
            ),
          ],
          fixedColor: Color.fromARGB(255, 15, 101, 239),
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}