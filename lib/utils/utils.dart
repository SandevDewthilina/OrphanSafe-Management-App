import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Utils {
  static late WebViewController controller;
  static Future<String?> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return '${androidDeviceInfo.model} ${androidDeviceInfo.id}'; // unique ID on Android
    } else {
      return "UnknownDeviceIDFromFlutter";
    }
  }

  static String getPatchTokenURL() {
    // return 'http://192.168.8.131:5010/api/notifications/patchToken';
    return 'https://orphansafe-management.ecodeit.com/api/notifications/patchToken';
  }

  static String getBaseURL() {
    return 'https://orphansafe-management.ecodeit.com/';
  }
  //
  // static Future<String> generateTokenPatchJSScript(userId, token) async {
  //   final deviceId = await Utils.getDeviceId();
  //   return '''
  //             const userId = ${userId.toString()}
  //             const token = '$token'
  //             const deviceId = '$deviceId'
  //             const payload = {
  //               userId: userId,
  //               token: token
  //             }
  //             const url = '${Utils.getPatchTokenURL()}'
  //             console.log(url)
  //             console.log(payload)
  //             fetch(url, {
  //             method: 'PATCH',
  //             headers: {
  //               'Content-Type': 'application/json', // You can adjust the content type as needed
  //             },
  //             body: 'JSON.stringify(payload)', // Convert the data object to a JSON string
  //             }).then((resp) => {
  //               console.log('response received')
  //             }).catch((e) => {
  //               console.log(e.message)
  //             })
  //
  //
  //             ''';
  // }

  static Future<String> getFCMToken() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('FCMToken')!;
  }

  static setWebViewController(WebViewController mController) {
    controller = mController;
  }
}