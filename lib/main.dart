import 'dart:io';
import 'dart:io' as io;
import 'package:encryptionapp/Encryption.dart';
import 'package:encryptionapp/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
  //mahcode
  Future<File> moveFile2(path, filename, destFolder) async {
    print('start');
    File sourceFile = File(path);
    print('start1');
    final checkPathExistence =
        await Directory('storage/emulated/0/EncryptedFiles/$destFolder')
            .exists();
    if (!checkPathExistence) {
      var testdir = await new io.Directory(
              'storage/emulated/0/EncryptedFiles/$destFolder')
          .create(recursive: true);
    } else {
      print('Pehle se hi hai');
    }

    try {
      // prefer using rename as it is probably faster
      print('end1');
      return await sourceFile.rename(
          'storage/emulated/0/EncryptedFiles/$destFolder/$filename.aes');
    } on FileSystemException catch (e) {
      print(e);

      final newFile = await sourceFile
          .copy('storage/emulated/0/EncryptedFiles/$destFolder/$filename.aes');
      print('end');
      await sourceFile.delete();
      return newFile;
    }
  }

  void encryptfileforfolder(path, String destFolder) async {
    print('File path recieved $path');

    var name = basename(path);
    String encryptedFilePath = EncryptData.encrypt_file(path);
    print(encryptedFilePath);
    moveFile2(encryptedFilePath, name, destFolder);
  }

  void _listofFilesfromFolder(String folderPath) async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      files = io.Directory("storage/emulated/0/$folderPath/")
          .listSync(); //use your folder name insted of resume.
    });

    print(files.runtimeType);
  }

  //Declare Globaly
  String directory;
  List file = new List();
  List files = new List();

  bool statusOfFolderFilesEncryption = false;
  // Make New Function
  void _listofFiles() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      file = io.Directory("storage/emulated/0/EncryptedFiles/")
          .listSync(); //use your folder name insted of resume.
    });

    print(file.runtimeType);
  }

  //mahCodeEnds😛

  List<String> imageUrls = [];

  String _path;
  Map<String, String> _paths;
  bool _multiPick = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<String> openFileExplorer() async {
    try {
      _path = null;
      _paths = await FilePicker.getMultiFilePath(type: FileType.video);

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
    // TODO: implement initState
    super.initState();
    request();
    _listofFiles();
    print(
        '\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$ ${file.length}\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$');
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

  Future<String> decryptfile(BuildContext context) async {
    File file = await FilePicker.getFile();
    String filepath = file.path;
    print('File path recieved $filepath');
    String spath = filepath.substring(1, filepath.length);
    print('File slashed path is $spath');
    String decryptedFilePath = await EncryptData.decrypt_file(spath);
    await print(
        '-----------------------${decryptedFilePath}-----------------------------');
    File filePlayed = await File(decryptedFilePath);

    if (filePlayed != null) {
      print(filePlayed.path);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayer(
            path: filePlayed.path,
          ),
        ),
      );
    } else {}

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

  String destFolderPath;
  TextEditingController tc = new TextEditingController();
  TextEditingController tc2 = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    _listofFiles();
    double width = MediaQuery.of(context).size.width;
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
            Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: tc,
                  ),
                )),
            InkWell(
              onTap: () async {
                statusOfFolderFilesEncryption = false;
                await _listofFilesfromFolder(tc.text);
                destFolderPath = tc2.text;
                for (int i = 0; i < files.length; i++) {
                  encryptfileforfolder(files[i].path, destFolderPath);
                }
                await setState(() {
                  print('ho gaya');
                });
                statusOfFolderFilesEncryption = true;
              },
              child: Card(
                  color: Colors.black54,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Encrypt all in the folder',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            ),
            Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: tc2,
                  ),
                )),

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
                decryptfile(context).then((value) => _scaffoldKey.currentState
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
                      'Decrypt file',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            ),
            InkWell(
              onTap: () async {
                File filePlayed = await FilePicker.getFile(); //Meeeooowwwww
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayer(
                      path: filePlayed.path,
                    ),
                  ),
                );
              },
              child: Card(
                  color: Colors.black54,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Play a video',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      // your Content if there
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Folder Contents',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: file.length,
                            itemBuilder: (BuildContext context, int index) {
                              return file[index].toString().contains('.aes') ||
                                      (!file[index].toString().contains('.'))
                                  ? InkWell(
                                      onTap: () {
                                        if (!basename(
                                                file[index].toString().trim())
                                            .toString()
                                            .substring(
                                                0,
                                                basename(file[index]
                                                            .toString()
                                                            .trim())
                                                        .toString()
                                                        .length -
                                                    1)
                                            .contains('.aes')) {}
                                      },
                                      child: Card(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(basename(
                                                file[index].toString().trim())
                                            .toString()
                                            .substring(
                                                0,
                                                basename(file[index]
                                                            .toString()
                                                            .trim())
                                                        .toString()
                                                        .length -
                                                    1)),
                                      )),
                                    )
                                  : Container();
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ),
//            InkWell(
//              onTap: () async {
//                File file = await FilePicker.getFile();
//                String filepath = file.path;
//                print('File path recieved $filepath');
//                File filePlayed = File(filepath);
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (context) => VideoPlayer(
//                      video: filePlayed,
//                    ),
//                  ),
//                );
//              },
//              child: Card(
//                  color: Colors.black54,
//                  elevation: 10,
//                  shape: RoundedRectangleBorder(
//                      borderRadius: BorderRadius.all(Radius.circular(10))),
//                  child: Padding(
//                    padding: const EdgeInsets.all(18.0),
//                    child: Text(
//                      'Play',
//                      style: TextStyle(color: Colors.white),
//                    ),
//                  )),
//            ),
          ],
        ),
      ),
    );
  }
}
