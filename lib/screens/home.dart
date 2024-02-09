import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'live_stream.dart';
import '../components/photo_select.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  SharedPreferences ? prefs;
  List<FileSystemEntity> ? _files;
  File ? _profilePicture;
  Directory ? fileDirectory;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _numberOfViewersController = TextEditingController();
  bool _verification = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real stream')),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 25,
          bottom: 25,
          left: 15,
          right: 15
        ),
        child: Center(
          child: Column(
            children: [
              const PhotoSelect(),
              TextField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your username'
                ),
                controller: _usernameController,
                onChanged: (value) async {
                  await prefs?.setString('username', value);
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Enter base for viewer count",
                  helperText: 'Number of views will go up and down from this number',
                  counterText: ''
                ),
                maxLength: 6,
                controller: _numberOfViewersController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
                onChanged: (value) async {
                  await prefs?.setString('number_of_viewers', value);
                },
              ),
              SwitchListTile(
                value: _verification,
                onChanged: (bool value) async {
                  await prefs?.setBool('verification', value);
                  setState(() {
                    _verification = value;
                  });
                },
                activeColor: Colors.blue,
                title: const Text(
                  'Display verification badge',
                  style: TextStyle(fontSize: 16)
                ),
                contentPadding: const EdgeInsets.all(0),
                dense: true,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LiveStream(
                      profilePicture: _profilePicture != null ? _profilePicture! : File(''),
                      profileName: _usernameController.text,
                      numberOfViewers: int.parse(_numberOfViewersController.text),
                      verification: _verification
                    )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.amber
                ),
                child: const Text('Start live stream'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future initData() async {
    fileDirectory = await getApplicationDocumentsDirectory();
    final directory = await Directory('${fileDirectory!.path}/applicationImages').create(recursive: true);
    _files = directory.listSync(recursive: true, followLinks: false);
    if (_files!.isNotEmpty) {
      setState(() {
        _profilePicture = File(_files![0].path);
      });
    }
    prefs = await SharedPreferences.getInstance();
    _usernameController.text = prefs!.getString('username') ?? '';
    _numberOfViewersController.text = prefs!.getString('number_of_viewers') ?? '300';
    setState(() {
      _verification = prefs!.getBool('verification') ?? false;
    });
  }
}
