import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';

class PhotoSelect extends StatefulWidget {
  const PhotoSelect({super.key});

  @override
  State<PhotoSelect> createState() => _PhotoSelectState();
}

class _PhotoSelectState extends State<PhotoSelect> {
  List<FileSystemEntity> ? _files;
  Directory ? fileDirectory;
  File ? _selectedImage;
  BuildContext ? _alertDialogContext;

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
    return TextButton(
      onPressed: () {
        _showPhotoSelectDialog();
      },
      style: TextButton.styleFrom(
        elevation: 0,
        foregroundColor: Theme.of(context).canvasColor // Disables ripple effect on click, make sure it same as backghround transparent doesnt work
      ),
      child: _selectedImage != null ?
        CircleAvatar(
          radius: 53,
          backgroundColor: Colors.white,
          backgroundImage: Image.file(_selectedImage!).image
        )
        : 
        const CircleAvatar(
          radius: 53,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/default_profile_picture.png'),
          child: Text(
            'YOUR PHOTO HERE',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        )
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    Navigator.of(_alertDialogContext!).pop();

    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
    if (_selectedImage == null || fileDirectory == null) return;
    await _selectedImage?.copy('${fileDirectory?.path}/applicationImages/profileImage${p.extension(_selectedImage!.path)}');
  }

  Future _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    Navigator.of(_alertDialogContext!).pop();

    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
    if (_selectedImage == null || fileDirectory == null) return;
    await _selectedImage?.copy('${fileDirectory?.path}/applicationImages/profileImage${p.extension(_selectedImage!.path)}');
  }

  Future<void> _showPhotoSelectDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        _alertDialogContext = context;
        return AlertDialog(
          title: const Text('Choose'),
          titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 10),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _pickImageFromCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5)
                    ),
                    child: const Column(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightCamera,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 5),
                        Text('Camera')
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _pickImageFromGallery();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5)
                    ),
                    child: const Column(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightImage,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 5),
                        Text('Gallery')
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future initData() async {
    fileDirectory = await getApplicationDocumentsDirectory();
    final directory = await Directory('${fileDirectory!.path}/applicationImages').create(recursive: true);
    _files = directory.listSync(recursive: true, followLinks: false);
    if (_files!.isNotEmpty) {
      setState(() {
        _selectedImage = File(_files![0].path);
      });
    }
  }
}