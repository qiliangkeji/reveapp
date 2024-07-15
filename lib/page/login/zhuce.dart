import 'package:flutter/material.dart';
import 'package:flutter_application_2/exception/DebugReportException.dart';
import 'package:flutter_application_2/util/SpUtils.dart';
import 'package:flutter_application_2/api/AuthApi.dart';
import 'dart:convert';

/// 注册页
class Zhuce extends StatefulWidget {
  final String? optionalParam; // 可选参数

  // 构造函数，接受一个可选的String参数
  const Zhuce({Key? key, this.optionalParam}) : super(key: key);

  @override
  _ZhuceState createState() => _ZhuceState();
}

class _ZhuceState extends State<Zhuce> {
  String _siteName = '注册';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();

  String _captchaImageUrl = '';

  @override
  Widget build(BuildContext context) {
    final pageHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_siteName),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: pageHeight * 0.03),
                  _buildLogo(),
                  SizedBox(height: pageHeight * 0.025),
                  _buildTitle(),
                  SizedBox(height: pageHeight * 0.015),
                  _buildForm(),
                ],
              ),
            ),
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
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hintText: '用户邮箱',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordController,
          hintText: '登录密码',
          icon: Icons.lock,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(height: 8),
        _buildCaptchaField(),
        const SizedBox(height: 10),
        _buildRegisterButton(),
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
      width: double.infinity,
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white38,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon),
        ),
        keyboardType: keyboardType,
        style: const TextStyle(height: 1.0),
      ),
    );
  }

  Widget _buildCaptchaField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _buildTextField(
            controller: _captchaController,
            hintText: '验证码',
            icon: Icons.lock,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _fetchCaptcha,
          child: _captchaImageUrl.isNotEmpty
              ? Image.memory(
            base64Decode(_captchaImageUrl.split(',')[1]),
            width: 100,
            height: 50,
          )
              : Container(width: 100, height: 50, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
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
          "注册",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onPressed: () => _register(context),
      ),
    );
  }

  Future<void> _getTitle() async {
    var result = await SpUtils.getString('CurrentTitle');
    setState(() {
      _siteName = result ?? '注册';
    });
  }

  Future<void> _fetchCaptcha() async {
    // 调用验证码接口获取图片
    var result = await AuthApi.yzm();
    setState(() {
      _captchaImageUrl = result['data'];
    });
  }

  Future<void> _register(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      throw FormatException('邮箱不能为空');
    }
    if (_passwordController.text.isEmpty) {
      throw FormatException('密码不能为空');
    }
    if (_captchaController.text.isEmpty) {
      throw FormatException('验证码不能为空');
    }

    var result = await AuthApi.zhuce({
      'userName': _emailController.text,
      'Password': _passwordController.text,
      'captchaCode': _captchaController.text,
    });

    if (result['code'] == 40032) {
      throw DebugReportException('该邮箱已注册');
    } else if (result['code'] == 0) {
      // 注册成功
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('注册成功，请登录')),
      );
      Navigator.pop(context); // 返回登录页面
    }
  }
}