import 'dart:io';
import 'package:encryptionapp/Encryption.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:permissions_plugin/permissions_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  List<String> imageUrls = [];

  String _path;
  Map<String, String> _paths;
  bool _multiPick = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<String> openFileExplorer() async {
    try {
      _path = null;
      _paths = await FilePicker.getMultiFilePath(type: FileType.image);

      encryptFiles();
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return 'null';
    return 'Success';
  }

  encryptFiles() {
    _paths.forEach((fileName, filePath) => {encryptfile(filePath)});
  }

  @override
  void initState() {
    request();
  }

  void request() async {
    Map<Permission, PermissionState> permission =
        await PermissionsPlugin.requestPermissions([
      Permission.WRITE_EXTERNAL_STORAGE,
      Permission.READ_EXTERNAL_STORAGE
    ]);
  }

  void encryptfile(path) async {
    print('File path recieved $path');
    String spath = path.substring(1, path.length);
    print('File slashed path is $spath');
    var name = basename(path);
    String encryptedFilePath = EncryptData.encrypt_file(spath);
    print(encryptedFilePath);
    moveFile(encryptedFilePath, name);
  }

  Future<String> decryptfile() async {
    File file = await FilePicker.getFile();
    String filepath = file.path;
    print('File path recieved $filepath');
    String spath = filepath.substring(1, filepath.length);
    print('File slashed path is $spath');
    String decryptedFilePath = EncryptData.decrypt_file(spath);
    print(decryptedFilePath);
    Fluttertoast.showToast(
        msg:
            'Encryption successful.\nEncrypted file path : $decryptedFilePath');
    return 'Success';
  }

  Future<File> moveFile(path, filename) async {
    print('start');
    File sourceFile = File(path);
    print('start1');
    try {
      // prefer using rename as it is probably faster
      print('end1');
      return await sourceFile
          .rename('storage/emulated/0/EncryptedFiles/$filename.aes');
    } on FileSystemException catch (e) {
      print(e);

      final newFile = await sourceFile
          .copy('storage/emulated/0/EncryptedFiles/$filename.aes');
      print('end');
      await sourceFile.delete();
      return newFile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text('Encryption-Decryption Module'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                openFileExplorer().then((value) => _scaffoldKey.currentState
                    .showSnackBar(
                        SnackBar(content: Text('Successfully Encrypted'))));
              },
              child: Card(
                  color: Colors.black54,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Select and encrypt files',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            ),
            InkWell(
              onTap: () {
                decryptfile().then((value) => _scaffoldKey.currentState
                    .showSnackBar(
                        SnackBar(content: Text('Successfully Decrypted'))));
              },
              child: Card(
                  color: Colors.black54,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Decrypt files',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
