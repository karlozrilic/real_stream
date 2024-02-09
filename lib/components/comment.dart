import 'dart:async';
import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  const Comment({
    super.key,
    required this.profileImage,
    required this.handle,
    required this.name,
    required this.comment
  });

  final String profileImage;
  final String handle;
  final String name;
  final String comment;

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  String profileImage = 'assets/default_profile_picture.png';
  String handle = '';
  String name = '';
  String comment= '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage(profileImage)
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(comment)
            ],
          ),
        )
      ],
    );
  }

  Future initData() async {
    profileImage = widget.profileImage;
    handle = widget.handle;
    name = widget.name;
    comment = widget.comment;
  }
}