import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:video_record_upload/tutorial.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft, //横固定
    DeviceOrientation.landscapeRight,
  ]);
  await Firebase.initializeApp();

  runApp(
      ScreenUtilInit(
        builder: (_, child) {
          return Tutorial();
        },
        designSize: const Size(1080, 810),
        minTextAdapt: true,
        splitScreenMode: true,
      )
  );
}
