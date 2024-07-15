import 'package:flutter/material.dart';
import 'package:flutter_application_2/exception/DebugReportException.dart';
import 'package:flutter_application_2/page/index/index.dart';
import 'package:flutter_application_2/page/login/users.dart';
import 'package:flutter_application_2/page/login/zhuce.dart';
import 'package:flutter_application_2/util/SpUtils.dart';
import 'package:flutter_application_2/util/StringUtil.dart';
import 'package:flutter_application_2/api/AuthApi.dart';
import 'dart:convert';

import '../../config/SlideUpPageRoute.dart';

/// 登录页
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _siteName = '登录';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;
    final pageHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: pageHeight * 0.03),
              _buildLogo(),
              SizedBox(height: pageHeight * 0.025),
              _buildTitle(),
              SizedBox(height: pageHeight * 0.015),
              _buildLoginForm(),
              SizedBox(height: 10),
              _buildLoginButton(context),
              SizedBox(width: 15),
              _buildRegisterButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        'images/favicon.ico',
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _siteName,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hintText: '用户邮箱',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 8),
        _buildTextField(
          controller: _passwordController,
          hintText: '登录密码',
          icon: Icons.lock,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: 350,
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white38,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon),
        ),
        keyboardType: keyboardType,
        style: TextStyle(height: 1.0),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      width: 350,
      height: 55,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        child: const Text(
          "登录",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onPressed: () => _login(context),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.people_alt,
        color: Colors.orangeAccent,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Zhuce()),
        );
      },
    );
  }

  Future<void> _getTitle() async {
    var result = await SpUtils.getString('CurrentTitle');
    setState(() {
      _siteName = result;
    });
  }

  Future<void> _login(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      throw FormatException('邮箱不能为空');
    }
    if (_passwordController.text.isEmpty) {
      throw FormatException('密码不能为空');
    }

    var result = await AuthApi.login({
      'userName': _emailController.text,
      'Password': _passwordController.text,
      'captchaCode': ''
    });

    if (result['code'] == 40020) {
      throw DebugReportException('邮箱或密码错误');
    }

    var siteUrl = await SpUtils.getString('CurrentBaseUrl');
    Map<String, dynamic> userInfo = {
      'data': result['data'],
      'userName': _emailController.text,
      'Password': _passwordController.text,
      'siteName': _siteName,
      'siteUrl': siteUrl
    };
    _convertAvatar(siteUrl, userInfo['data']);

    final accountList = <String>[json.encode(userInfo)];
    List<String> localList = await SpUtils.getStringList('accounts');

    if (localList.isNotEmpty) {
      for (var value in localList) {
        Map<String, dynamic> jsonData = json.decode(value);
        if (jsonData['siteUrl'] != siteUrl ||
            jsonData['userName'] != userInfo['userName']) {
          _convertAvatar(siteUrl, jsonData['data']);
          accountList.add(value);
        }
      }
    }

    await SpUtils.setString('currentUserName', _emailController.text);
    await SpUtils.setStringList('accounts', accountList);
    await SpUtils.setString('userInfo', json.encode(userInfo));
    await SpUtils.setBool("isLogin", true);
    await SpUtils.setString('currentMenu', '/');

    Navigator.pushReplacementNamed(context, "/");
  }

  void _convertAvatar(String siteUrl, Map<String, dynamic> jsonData) {
    String avatar = '$siteUrl/api/v3/user/avatar/${jsonData['id']}/s';
    jsonData['avatar'] = avatar;
  }
}