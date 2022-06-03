import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spring_button/spring_button.dart';
import 'package:path/path.dart';
import 'package:video_record_upload/api/firebase_api.dart';
import 'package:video_record_upload/api/python_api.dart';
import 'package:video_record_upload/recommend.dart';
import 'package:video_record_upload/test.dart';

class Review extends StatefulWidget{
  Review(this.file, {Key? key}) : super(key: key);
  XFile? file;
  @override
  // ignore: no_logic_in_create_state
  State<Review> createState() => _ReviewState(file);
}

// ignore: must_be_immutable
class _ReviewState extends State<Review> {
  _ReviewState(this.file);
  XFile? file;
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
      height: 85,
      width: 125,
      child: SpringButton(
          SpringButtonType.WithOpacity,
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 26, 67, 1),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    Text(
                      '終了',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
      height: 100,
      width: 250,
      child: SpringButton(
        SpringButtonType.WithOpacity,
        Padding(
          padding: const EdgeInsets.all(12.5),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(203, 44, 0, 1.0),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.file_upload,
                    color: Colors.white,
                    size: 45,
                  ),
                  Text(
                    '動画を送信',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () async {
          //Firebaseへ送信＆計算＆画面遷移
          await calculateVideo(file, context);

          print("Video Path ${file!.path}");
          //_controller?.play();
        },
      ),
    );
  }

  Widget retakeButton(BuildContext context) {
    return SizedBox(
      height: 85,
      width: 150,
      child: SpringButton(
          SpringButtonType.WithOpacity,
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(125, 2, 10, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 30,
                    ),
                    Text(
                      '撮り直す',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
                  alignment: const Alignment(0.98, 1.02),
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

Future<void> calculateVideo(XFile? videoFile, BuildContext context) async {
  print("Uploading Video");

  if (videoFile == null) return;

  //AndroidかiOSかを確認
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? userID;
  if(Platform.isAndroid) {
    AndroidDeviceInfo infoID = await deviceInfo.androidInfo;
    userID = infoID.androidId;
    print('Runnning on ${infoID.androidId}');
  }
  else if(Platform.isIOS) {
    IosDeviceInfo infoID = await deviceInfo.iosInfo;
    userID = infoID.identifierForVendor;
    print('Runnning on ${infoID.identifierForVendor}');
  }
  else {
    //その他の機器の場合、noNameフォルダへ送信
    userID = "noName";
  }

  //Convert so it can be uploaded
  File file = File(videoFile.path);

  final fileName = basename(file.path);
  final folderName = fileName.substring(0, fileName.length - 4);
  final firebaseDest = 'userFiles/$userID/$folderName/$fileName';

  print("A");
  print(fileName);
  print(firebaseDest);
  print("B");

  //await FirebaseApi.uploadFile(firebaseDest, file);

  //python APIを叩く→firebaseに入ってる場所を取得できる
  //final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/user_videos?user_id=${userID}&video_id=${folderName}'));
  //final response = await http.get(Uri.parse('https://joshuaravishankar-fa39413gbz992ckl.socketxp.com/api/?user_id=${userID}&video_id={$folderName}&technique_id=forehand_shakehold'));
  //final response = await http.get(Uri.parse('https://joshuaravishankar-fa39413gbz992ckl.socketxp.com/api/?user_id=PengZhiyu&video_id=completely_wrong&technique_id=forehand_shakehold'));
  //print(response.statusCode);
  //print(jsonDecode(response.body));
  //print(response.body);

  //firebaseからもってくる処理
  //XFile videoLocation = await FirebaseApi.downloadFile("userFiles/PengZhiyu/completely_wrong/recommendation.mp4");
  print("download OK");

  final storageRef = FirebaseStorage.instance.ref();
  final imageUrl = await storageRef.child("userFiles/PengZhiyu/completely_wrong/recommendation.mp4").getDownloadURL();

  //final videoData = FirebaseApi.downloadFile(firebaseDest);

  //画面遷移
  /*Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Test(imageUrl)),
  );*/
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

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