import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_record_upload/pro_video.dart';
import 'package:video_record_upload/test.dart';
import 'package:video_record_upload/stream.dart';
import 'package:video_record_upload/test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // リスト一覧画面を表示
      body: Menupage(),
    );
  }
}

// リスト一覧画面用Widget
class Menupage extends StatefulWidget {
  const Menupage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<Menupage> {
  // ignore: non_constant_identifier_names
  Widget VideoInfo(String id) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(1.w, 5.h, 1.w, 5.h),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              image: AssetImage("assets/image/thumbnail${id}.jpg"),
              width: 450.w,
              height: 225.h,
              fit: BoxFit.fill,
            ),
            Container(
              width: 5.w,
              height: 225.h,
              color: Colors.white,
            ),
            Image(
              image: AssetImage("assets/image/explain${id}.jpg"),
              width: 450.w,
              height: 225.h,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.w),
            ),
            SizedBox(
              width: 75.w,
              height: 75.w,
              child: ElevatedButton(
                child: Text(
                  '選択',
                  style: TextStyle(
                    fontSize: 21.sp,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(252, 141, 78, 1.0),
                  onPrimary: Colors.black,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: Colors.white,
                      width: 1.w,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                onPressed: () async {
                  /*await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StackedVideoView()),
                );*/

                  //ビデオ取得のテスト
                  //final storageRef = FirebaseStorage.instance.ref();
                  //final imageUrl = await storageRef.child("/userFiles/PengZhiyu/completely_wrong/recommendation.mp4").getDownloadURL();
                  //print(imageUrl);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProVideo(id)),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget VideoInfo_none(String id) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(1.w, 5.h, 1.w, 5.h),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              image: AssetImage("assets/image/unpub_thumbnail.jpg"),
              width: 450.w,
              height: 225.h,
              fit: BoxFit.fill,
            ),
            Container(
              width: 5.w,
              height: 225.h,
              color: Colors.white,
            ),
            Image(
              image: AssetImage("assets/image/unpub_explain.jpg"),
              width: 450.w,
              height: 225.h,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.w),
            ),
            SizedBox(
              width: 75.w,
              height: 75.w,
              child: ElevatedButton(
                child: Text(
                  '選択',
                  style: TextStyle(
                    fontSize: 21.sp,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  //primary: const Color.fromRGBO(252, 141, 78, 1.0),
                  onPrimary: Colors.black,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: Colors.white,
                      width: 1.w,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                onPressed: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    print(size);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 215, 130, 1),
      // AppBarを表示し、タイトルも設定
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Image(
          image: AssetImage("assets/image/logo.png"),
          width: 180.w,
          fit: BoxFit.fill,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Sorry... This Function isn't implemented"),
              ));
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Sorry... This Function isn't implemented"),
              ));
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      // データを元にListViewを作成
      body: Center(
        child: Container(
          color: const Color.fromRGBO(255, 215, 130, 1.0),
          height: 750.h,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                for (int i = 1; i <= 3; i++) VideoInfo(i.toString()),
                for (int i = 1; i <= 7; i++) VideoInfo_none(i.toString()),
                Padding(
                  padding: EdgeInsets.fromLTRB(1.w, 5.h, 1.w, 5.h),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
