import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geek_findr/controller/controller.dart';
import 'package:geek_findr/theme.dart';
import 'package:geek_findr/views/login_page.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AppController());
    final mobileTheme = SchedulerBinding.instance!.window.platformBrightness;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: mobileTheme == Brightness.light ? AppTheme.light : AppTheme.dark,
      home: const LoginPage(),
    );
  }
}
