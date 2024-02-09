import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:real_stream/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/comments_list.dart';
import '../components/comment.dart';
import 'dart:developer' as dev;

class LiveStream extends StatefulWidget {
  const LiveStream({
    super.key,
    required this.profilePicture,
    required this.profileName,
    required this.numberOfViewers,
    required this.verification
  });

  final File profilePicture;
  final String profileName;
  final int numberOfViewers;
  final bool verification;

  @override
  State<LiveStream> createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> with SingleTickerProviderStateMixin {
  CameraController? controller;
  File ? imageFile;
  String profileName = "";
  int numberOfViewers = 96; // 96 is default
  bool verification = false;
  bool _isRearCameraSelected = false;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  List<Comment> commentsStore = List.from(commentsList);
  final List<Comment> comments = List.from([]);

  late AnimationController expandController;
  late Animation<double> animation; 

  @override
  void initState() {
    super.initState();
    initCamera(cameras![1]);
    // initCamera(cameras![0]);
    imageFile = widget.profilePicture;
    profileName = widget.profileName;
    numberOfViewers = widget.numberOfViewers;
    verification = widget.verification;
    int randomPercentage = numberBetween(min: 1, max: 5);
    int percentage = percentOfNumber(number: numberOfViewers, percent: randomPercentage);

    prepareAnimations();

    // Run every second
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) {
        listKey.currentState?.insertItem(0,
          duration: const Duration(milliseconds: 200)
        );
        addRandomComment();

        setState(() {
          numberOfViewers = numberBetween(min: numberOfViewers - percentage, max: numberOfViewers + percentage);
        });
      }
    });
  }

  // Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500)
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    if (!controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Transform.scale(
              scale: controller!.value.aspectRatio/deviceRatio,
              child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: CameraPreview(controller!),
              ),
            ),
          ),
          Positioned(
            left: 10.0,
            top: 30.0,
            bottom: 10.0,
            width: size.width - 10 - 10, // width of screen - 10px from left and 10px from right
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          backgroundImage: Image.file(imageFile!).image
                        ),
                        const SizedBox(width: 10),
                        Text(profileName),
                        const SizedBox(width: 5),
                        if (verification) 
                        const FaIcon(
                            FontAwesomeIcons.solidBadgeCheck,
                            color: Colors.blue,
                            size: 15,
                        ),
                        const SizedBox(width: 5),
                        const FaIcon(
                          FontAwesomeIcons.angleDown,
                          color: Colors.white,
                          size: 15,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xffE1306C),
                            borderRadius: BorderRadius.all(Radius.circular(2))
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xcc000000),
                            borderRadius: BorderRadius.all(Radius.circular(2))
                          ),
                          child: Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.eye,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                formatNumberOfViews(numberOfViewers),
                                style: const TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          iconSize: 35,
                          icon: const FaIcon(
                            FontAwesomeIcons.xmark,
                            color: Colors.white,
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 5),
                    const IconButton(
                      onPressed: null,
                      iconSize: 30,
                      icon: FaIcon(
                        FontAwesomeIcons.lightMicrophone,
                        color: Colors.white,
                      )
                    ),
                    const IconButton(
                      onPressed: null,
                      iconSize: 25,
                      icon: FaIcon(
                        FontAwesomeIcons.lightVideo,
                        color: Colors.white,
                      )
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _isRearCameraSelected = !_isRearCameraSelected);
                        initCamera(cameras![_isRearCameraSelected ? 0 : 1]);  
                      },
                      iconSize: 30,
                      icon: const FaIcon(
                        FontAwesomeIcons.lightArrowsRotate,
                        color: Colors.white,
                      )
                    ),
                    const IconButton(
                      onPressed: null,
                      iconSize: 30,
                      icon: FaIcon(
                        FontAwesomeIcons.lightSparkles,
                        color: Colors.white,
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            width: size.width,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        disabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: Colors.white, width: 1.0)
                        ),
                        labelText: 'Comment...',
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.white
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const FaIcon(
                            FontAwesomeIcons.lightEllipsis,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightVideoPlus,
                          color: Colors.white,
                          size: 25,
                        ),
                        FaIcon(
                          FontAwesomeIcons.lightUserPlus,
                          color: Colors.white,
                          size: 25,
                        ),
                        FaIcon(
                          FontAwesomeIcons.lightCommentQuestion,
                          color: Colors.white,
                          size: 25,
                        ),
                        FaIcon(
                          FontAwesomeIcons.lightPaperPlaneTop,
                          color: Colors.white,
                          size: 25,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ),
          Positioned(
            bottom: 85,
            left: 10,
            width: (size.width / 4 * 3) - 10,
            child: LimitedBox(
              maxHeight: 250,
              child: AnimatedList(
                physics: const NeverScrollableScrollPhysics(),
                reverse: true,
                key: listKey,
                initialItemCount: comments.length,
                itemBuilder: (context, index, animation) {
                  if (index == 0) { // Because list is reversed
                    return slideIt(context, index, animation);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: slideIt(context, index, animation),
                    );
                  }
                }
              ),
            )
          ),
          Positioned(
            bottom: 85,
            right: 10,
            width: (size.width / 4) - 10,
            child: const TextField(
              enabled: false,
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: Colors.white, width: 1.0)
                ),
                labelText: 'Comment...',
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.white
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)
              ),
            )
          )
        ] 
      ),
    );
  }

  Future initCamera(CameraDescription cameraDescription) async {
    controller =
        CameraController(cameraDescription, ResolutionPreset.max);
    try {
      await controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  int percentOfNumber({required int number, required int percent}) {
    return (number * percent / 100).round();
  }

  int numberBetween({required int min, required int max}) {
    min = min.abs();
    max = max.abs();
    if (max > 1000000) {
      max = 1000000;
    }
    if (min > max) {
      min = max;
      max = min;
    }
    return min + Random().nextInt(max - min + 1);
  }

  String formatNumberOfViews(int number) {
    String formatted = '$number';
    if (number > 1000) {
      formatted = '${double.parse((number/1000).toStringAsFixed(1))}k';
    }
    if (number > 1000000) {
      formatted = '${double.parse((number/1000).toStringAsFixed(1))}m';
    }
    return formatted;
  }

  addRandomComment() {
    comments.insert(0, (List.of(commentsStore)..shuffle()).first);
  }

  Widget slideIt(BuildContext context, int index, animation) {
    Comment item = comments[index];
    SizeTransition sizeTransition = SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: item
    );
    animation.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        // custom code here
      }
    }); 
    return sizeTransition;
    // return SlideTransition(
    //   position: Tween<Offset>(
    //     begin: const Offset(-1, 0),
    //     end: const Offset(0, 0),
    //   ).animate(animation),
    //   child: item,
    // );
  }
}
