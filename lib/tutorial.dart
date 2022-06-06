import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:video_record_upload/menu.dart';

const MaterialColor customSwatch = MaterialColor(
  0xFFB71C1C,
  <int, Color>{
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(0xFFF44336),
    600: Color(0xFFE53935),
    700: Color(0xFFD32F2F),
    800: Color(0xFFC62828),
    900: Color(0xFFB71C1C),
  },
);


class Tutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: customSwatch,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TutorialState(),
    );
  }
}

class TutorialState extends StatelessWidget {
  TutorialState({Key? key}) : super(key: key);

  //buildを描く

  final pages = [
    PageModel(
        color: const Color(0xFF95cedd),
        imageAssetPath: 'assets/image/menu.png',
        title: 'まずメニューから練習したいフォームを選びます',
        body: 'あなたの卓球技術向上のため、様々なフォーム動画をご用意しております',
        doAnimateImage: true),
    PageModel(
        color: const Color(0xFF9B90BC),
        imageAssetPath: 'assets/image/pingpong.png',
        title: 'あなたのフォームを撮影し、動画を送信します',
        body: 'なるべく全身が映るように撮影してください',
        doAnimateImage: true),
    PageModel(
        color: const Color(0xFFF8CA6D),
        imageAssetPath: 'assets/image/phone.png',
        title: '少し待つとアドバイスが表示されます',
        body: '計算処理のため、約１〜２分お待ちください',
        doAnimateImage: true),
    PageModel.withChild(
        child: Padding(
            padding: EdgeInsets.only(bottom: 25.0.h),
            child: Text(
              "さあ、始めましょう！！！",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
              ),
            )),
        color: const Color(0xFF5886d6),
        doAnimateChild: true)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverBoard(
        pages: pages,
        showBullets: true,
        skipCallback: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Menu()),
          );
        },
        finishCallback: () async {
          // when user select NEXT
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Menu()),
          );
        },
      ),
    );
  }
}