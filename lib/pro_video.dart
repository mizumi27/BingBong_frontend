import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:video_record_upload/review.dart';


class ProVideo extends StatefulWidget{
  ProVideo(this.id, {Key? key}) : super(key: key);
  String id;

  @override
  State<ProVideo> createState() => _ProVideoState(id);
}

class _ProVideoState extends State<ProVideo> {

  _ProVideoState(this.id);
  String id;

  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.asset('assets/video/video$id.mp4');
    _controller?.initialize().then((_) {
      // 最初のフレームを描画するため初期化後に更新
      setState(() {});
      _controller?.setLooping(true);
      _controller?.setVolume(0);
      _controller?.play();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  Widget menuButton(BuildContext context) {
    return SizedBox(
      height: 100.h,
      width: 175.w,
      child: SpringButton(
        SpringButtonType.WithOpacity,
        Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 26, 67, 1),
              border: Border.all(color: Colors.white),
              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 50.sp,
                  ),
                  Text(
                    '戻る',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 80));
          Navigator.pop(context);
        }
      ),
    );
  }

  Widget cameraButton(BuildContext context) {
    return SizedBox(
      height: 115.h,
      width: 300.w,
      child: SpringButton(
        SpringButtonType.WithOpacity,
        Padding(
          padding: const EdgeInsets.all(12.5),
          child: Container(
            decoration:BoxDecoration(
              color: const Color.fromRGBO(125, 2, 10, 1.0),
              border: Border.all(color: Colors.white),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_rounded,
                    color: Colors.white,
                    size: 55.sp,
                  ),
                  Text(
                    '動画を撮影',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 60));
          await _controller?.pause();
          final XFile? file = await _picker.pickVideo(
              source: ImageSource.camera,
              maxDuration: const Duration(seconds: 10)
          );

          //動画を撮影しなかったときの処理
          if(file != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Review(file, id)),
            ).then((value) async {
              print("1");
            });
          }
          //await _controller?.initialize();
          await _controller?.setLooping(true);
          await _controller?.play();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 215, 130, 1),
      body: Stack(
        children: [
          //ここでプロの動画を再生したい
          VideoPlayer(_controller!),
          Align(
            alignment: const Alignment(0, 1.02),
            child: cameraButton(context),
          ),
          Align(
            alignment: const Alignment(-0.87, 1.02),
            child: menuButton(context),
          ),
        ],
      ),
    );
  }
}