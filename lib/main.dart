import 'dart:io';
import 'package:encryptionapp/Encryption.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void encryptfile() async {
    File file = await FilePicker.getFile();
    String filepath = file.path;
    print('File path recieved $filepath');
    String spath = filepath.substring(1, filepath.length);
    print('File slashed path is $spath');
    String encryptedFilePath = EncryptData.encrypt_file(filepath);
    print(encryptedFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FlatButton(
          onPressed: () {
            encryptfile();
          },
          child: Text('Encrypt file'),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
