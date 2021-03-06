// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:archive/archive.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Provider',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'compress strings',
        storage: Storage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Storage storage;
  final String title;

  const MyHomePage({Key? key, required this.title, required this.storage})
      : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController writeDataController = TextEditingController();
  TextEditingController readDataController = TextEditingController();
  TextEditingController freetextController = TextEditingController();
  String state = '';

  Future<Directory?>? _appDocumentsDirectory;

  @override
  void initState() {
    super.initState();

    setState(() {
      state = '';
      readDataController.text = '';
    });
    // automatischer leseversuch
    /*widget.storage.readData().then((String value) {
      setState(() {
        state = value;
        controllerRead.text = value;
      });
    });*/
  }

  void _zipData() {
    if (writeDataController.text != '') {
      var stringBytes = utf8.encode(writeDataController.text);
      var gzipBytes = GZipEncoder().encode(stringBytes);
      var compressedString = base64.encode(gzipBytes!);
      freetextController.text = compressedString;
    }
  }

  void _unzipData() {
    if (freetextController.text != '') {
      var compressedBytes = base64.decode(freetextController.text);
      var decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
      readDataController.text = new String.fromCharCodes(decompressedBytes);
    }
  }

Future<File> writeData() async {
  setState(() {
    state = writeDataController.text;
    writeDataController.text = '';
  });
  return widget.storage.writeData(state);
}

Future<void> readData2() async {
  widget.storage.readData().then((String value) {
    setState(() {
      state = value;
      readDataController.text = value;
    });
  });
}

Future<String> deleteFile3() async {
  setState(() {
    state = 'file deleted';
    readDataController.text = 'file del';
  });
  return widget.storage.deleteFile3();
}

Future<bool> fileExists3() async {
  bool ergebnis = false;
  widget.storage.fileExists().then((bool value) {
    setState(() {
      state = '';
      if (value == true) {
        freetextController.text = 'Datei existiert ';
      };
      if (value == false) {
        freetextController.text = 'Datei existiert NICHT';
      }
      ergebnis = value;
    });
  });
  return ergebnis;
}

/*
  Widget _buildDirectory(BuildContext context,
      AsyncSnapshot<Directory?> snapshot) {
    Text text = const Text('');
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        text = Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        text = Text('path: ${snapshot.data!.path}');
      } else {
        text = const Text('path unavailable');
      }
    }
    return Padding(padding: const EdgeInsets.all(16.0), child: text);
  }

  Widget _buildDirectories(BuildContext context,
      AsyncSnapshot<List<Directory>?> snapshot) {
    Text text = const Text('');
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        text = Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        final String combined =
        snapshot.data!.map((Directory d) => d.path).join(', ');
        text = Text('paths: $combined');
      } else {
        text = const Text('path unavailable');
      }
    }
    return Padding(padding: const EdgeInsets.all(16.0), child: text);
  }
*/
void _requestAppDocumentsDirectory() {
  setState(() {
    _appDocumentsDirectory = getApplicationDocumentsDirectory();
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Center(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: writeDataController,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Daten zum komprimieren',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Daten eingeben';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          textStyle: TextStyle(color: Colors.white)),
                      onPressed: () {
                        writeDataController.text = '';
                        // reset() setzt alle Felder wieder auf den Initalwert zur??ck.
                        //_formKey.currentState!.reset();
                      },
                      child: Text('Inhalt l??schen'),
                    ),
                    SizedBox(width: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          textStyle: TextStyle(color: Colors.white)),
                      onPressed: () {
                        //_requestAppDocumentsDirectory();
                        _zipData();
                        //writeData();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Daten wurden gepackt')),
                        );
                        // Wenn alle Validatoren der Felder des Formulars g??ltig sind.
                      },
                      child: Text('packen'),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          textStyle: TextStyle(color: Colors.white)),
                      onPressed: () {
                        //deleteFile3();
                        // reset() setzt alle Felder wieder auf den Initalwert zur??ck.
                        //_formKey.currentState!.reset();
                      },
                      child: Text('Datei l??schen'),
                    ),
                    SizedBox(width: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          textStyle: TextStyle(color: Colors.white)),
                      onPressed: () {
                        //_requestAppDocumentsDirectory();
                        _unzipData();
                        //readData2();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Daten wurden gelesen')),
                        );
                        // Wenn alle Validatoren der Felder des Formulars g??ltig sind.
                      },
                      child: Text('entpacken'),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                TextFormField(
                  controller: readDataController,
                  enabled: true, // false = disabled, true = enabled
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Daten zu lesen',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: freetextController,
                  maxLines: 5,
                  maxLength: 120,
                  decoration: InputDecoration(
                    hintText: 'Freitext',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          textStyle: TextStyle(color: Colors.white)),
                      onPressed: () {
                        // reset() setzt alle Felder wieder auf den Initalwert zur??ck.
                        //_formKey.currentState!.reset();
                      },
                      child: Text('nicht belegt'),
                    ),
                    SizedBox(width: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          textStyle: TextStyle(color: Colors.white)),
                      onPressed: () {
                        fileExists3();
                        // Wenn alle Validatoren der Felder des Formulars g??ltig sind.
                      },
                      child: Text('Datei existent ?'),
                    )
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    ),
  );
}}

class Storage {
  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/db.txt');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();

      return body;
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> writeData(String data) async {
    final file = await localFile;
    return file.writeAsString("$data");
  }

  Future<int> deleteFile() async {
    try {
      final file = await localFile;
      await file.delete();
      return 1;
    } catch (e) {
      return 0;
    }
  }

  Future<void> deleteFile2() async {
    try {
      final file = await localFile;
      await file.delete();
    } catch (e) {
      //return 0;
    }
  }

  Future<String> deleteFile3() async {
    try {
      final file = await localFile;
      await file.delete();
      return '1';
    } catch (e) {
      return '0';
    }
  }

  Future<bool> fileExists() async {
    try {
      final file = await localFile;
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
