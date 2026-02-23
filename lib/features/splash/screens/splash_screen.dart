import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/login_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';

class SplashScreen extends StatefulWidget {
  final Map<String, dynamic>? notificationData;
  final String? userName;
  const SplashScreen({super.key, this.notificationData, this.userName});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  late AnimationController _controller;
  late Animation<double> _animation; // تحديد النوع كـ double مباشرة

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشن
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward(); // تشغيل الأنميشن لمرة واحدة

    // تهيئة البيانات المشتركة
    Get.find<ConfigController>().initSharedData();

    // فحص الاتصال بالإنترنت
    _checkConnectivity();
  }

  void _checkConnectivity() {
    bool isFirst = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      // التحقق مما إذا كانت القائمة تحتوي على اتصال (وايفاي أو بيانات هاتف)
      bool isConnected = result.contains(ConnectivityResult.wifi) || 
                         result.contains(ConnectivityResult.mobile) ||
                         result.contains(ConnectivityResult.ethernet);

      if (!isFirst || !isConnected) {
        // استخدام Get.snackbar بدلاً من ScaffoldMessenger لتجنب مشاكل الـ Context
        Get.closeAllSnackbars();
        Get.snackbar(
          isConnected ? 'connected'.tr : 'no_connection'.tr,
          '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isConnected ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: isConnected ? 3 : 30),
          margin: const EdgeInsets.all(10),
        );

        if (isConnected) {
          LoginHelper().handleIncomingLinks(widget.notificationData, widget.userName);
        }
      } else {
        LoginHelper().handleIncomingLinks(widget.notificationData, widget.userName);
      }
      isFirst = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تخزين القيمة الحالية للأنيميشن لتسهيل القراءة
    final double animValue = _animation.value;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                  // تحريك العنصر من الأسفل (320) إلى مكانه الأصلي (0) بناءً على الأنيميشن
                  transform: Matrix4.translationValues(0, 320 * (1 - animValue), 0),
                  child: Column(
                    children: [
                      Opacity(
                        opacity: animValue,
                        child: Padding(
                          // تحريك جانبي بسيط أثناء الظهور
                          padding: EdgeInsets.only(left: 120 * (1 - animValue)),
                          child: SvgPicture.asset(
                            Images.splashSvgLogo,
                            width: 150, // يفضل تحديد عرض مناسب للوجو
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.25),
                      SvgPicture.asset(
                        Images.splashSvgBackground,
                        width: Get.width, // جعل الخلفية بعرض الشاشة
                        fit: BoxFit.cover,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
