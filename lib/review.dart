import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:video_record_upload/recommend.dart';


class Review extends StatefulWidget{

  Review(this.file, this.id, {Key? key}) : super(key: key);
  XFile? file;
  String id;
  @override
  // ignore: no_logic_in_create_state
  State<Review> createState() => _ReviewState(file, id);
}

// ignore: must_be_immutable
class _ReviewState extends State<Review> {
  _ReviewState(this.file, this.id);
  XFile? file;
  String id;
  VideoPlayerController? _controller;
  Future? test;

  @override
  void initState() {
    test = _playVideo(file);
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
                      '終了',
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
            Navigator.pop(context);
          }
      ),
    );
  }

  Widget sendButton(BuildContext context) {
    return SizedBox(
      height: 115.h,
      width: 300.w,
      child: SpringButton(
        SpringButtonType.WithOpacity,
        Padding(
          padding: const EdgeInsets.all(12.5),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(203, 44, 0, 1.0),
              border: Border.all(color: Colors.white),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_upload,
                    color: Colors.white,
                    size: 55.sp,
                  ),
                  Text(
                    '動画を送信',
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

          //画面遷移(計算はrecommend.dartで行う)
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Recommend(file, id)),
          );

          print("Video Path ${file!.path}");
          //_controller?.play();
        },
      ),
    );
  }

  Widget retakeButton(BuildContext context) {
    return SizedBox(
      height: 100.h,
      width: 230.w,
      child: SpringButton(
          SpringButtonType.WithOpacity,
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(125, 2, 10, 1.0),
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 50.sp,
                    ),
                    Text(
                      '撮り直す',
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 215, 130, 1),
      body: FutureBuilder(
        future: test,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {

            return Stack(
              children: [
                _previewVideo(),
                Align(
                  alignment: const Alignment(0, 1.02),
                  child: sendButton(context),
                ),
                Align(
                  alignment: const Alignment(-0.87, 1.02),
                  child: menuButton(context),
                ),
                Align(
                  alignment: const Alignment(0.87, 1.02),
                  child: retakeButton(context),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
  Widget _previewVideo() {

    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    //上のやつとここでプレビューを再生するか分岐している
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }


  // もういらないだろうけど、処理したビデオをユーザーに見せる際は使えるかも
  Future<void> _playVideo(XFile? file) async {

    //moutedを消去
    if (file != null) {
      print("Loading Video");
      await _disposeVideoController();
      late VideoPlayerController controller;
      /*if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {*/
      controller = VideoPlayerController.file(File(file.path));
      //}
      _controller = controller;
      // In web, most browsers won't honor a programmatic call to .play
      // if the video has a sound track (and is not muted).
      // Mute the video so it auto-plays in web!
      // This is not needed if the call to .play is the result of user
      // interaction (clicking on a "play" button, for example).

      //await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();

      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    else
    {
      print("Loading Video error");
    }
  }
  Future<void> _disposeVideoController() async {
    /*  if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;*/
    _controller = null;
  }
}

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}