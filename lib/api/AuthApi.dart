import 'package:flutter_application_2/util/DioUtil.dart';
import 'package:dio/dio.dart';

class AuthApi {
  // 获取云盘config信息
  static getConfig() async {
    var result =
    await DioUtil().request('/api/v3/site/config', method: DioMethod.get);
    return result;
  }

// 登录
  static login(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/user/session', method: DioMethod.post, data: params);
    return result;
  }

  //用户注册
  static zhuce(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/user', method: DioMethod.post, data: params);
    return result;
  }

  //验证码
  static yzm() async {
    var result =
    await DioUtil().request('/api/v3/site/captcha', method: DioMethod.get);
    return result;
  }

  //新建文件
  static wenj(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/file/create', method: DioMethod.post, data: params);
    return result;
  }

  //新建文件夹
  static wenjj(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/directory', method: DioMethod.put, data: params);
    return result;
  }

  //上传文件
  static shangc(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/file/upload', method: DioMethod.put, data: params);
    return result;
  }
  //上传文件到服务器
  static shangcwq(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/file/upload/{sessionID}/0', method: DioMethod.post, data: params);
    return result;
  }

  //下载文件
  static xiaz(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/user/', method: DioMethod.post, data: params);
    return result;
  }

  //删除文件
  static shanchu(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/user/', method: DioMethod.post, data: params);
    return result;
  }

  //分享文件
  static fenx(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/user/', method: DioMethod.post, data: params);
    return result;
  }

//重命名
  static chongmm(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/user/', method: DioMethod.post, data: params);
    return result;
  }

  //复制
  static fuzhi(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/user/', method: DioMethod.post, data: params);
    return result;
  }

  //移动
  static yidong(Map<String, dynamic> params) async {
    var result = await DioUtil()
        .request('/api/v3/user/', method: DioMethod.post, data: params);
    return result;
  }

}