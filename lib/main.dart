import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/api/AuthApi.dart';
import 'package:flutter_application_2/page/index/bottomBar.dart';
import 'package:flutter_application_2/page/index/index.dart';
import 'package:flutter_application_2/page/login/users.dart';
import 'package:flutter_application_2/util/SpUtils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_application_2/page/tools/customToast.dart';
import 'package:flutter_application_2/page/login/login.dart';
import 'package:flutter_application_2/handler/AppExceptionHandle.dart';
import 'package:flutter_application_2/exception/DebugReportException.dart';
import 'config/SlideUpPageRoute.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var isLogin = await SpUtils.getBool("isLogin");
  AppExceptionHandle().run(MyApp(
    isLogin: isLogin == null ? false : isLogin,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLogin;

  const MyApp({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaterialApp(
      title: 'FlutterReve',
      theme: theme,
      initialRoute: isLogin ? "/" : "/home",
      routes: {
        "/": (context) => Bottom(),
        "/login": (context) => Login(),
        "/home": (context) => MyHome(),
      },
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(
        toastBuilder: (String msg) => CustomToast(msg),
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<StatefulWidget> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    const String currentBaseUrl = "修改你的域名，不加斜杠";
    try {
      await SpUtils.setString('CurrentBaseUrl', currentBaseUrl);
      var result = await AuthApi.getConfig();
      await SpUtils.setString('CurrentTitle', result['data']['title']);
      await Future.delayed(Duration(seconds: 3)); // 等待三秒钟
      var isLogin = await SpUtils.getBool("isLogin");
      if (isLogin == true) {
        Navigator.pushNamed(context, "/");
      } else {
        Navigator.pushNamed(context, "/login");
      }
    } catch (e) {
      // Handle error
      print('Error initializing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/favicon.ico', height: 100), // 替换为你的logo路径
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              '正在初始化，请稍候...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}