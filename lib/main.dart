import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ImageClassifier(),
    );
  }
}

class ImageClassifier extends StatefulWidget {
  const ImageClassifier({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImageClassifierState createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<ImageClassifier> {
  File? _image;
  List? _output;

  @override
  void initState() {
    super.initState();
    loadModel().then((_) {
      setState(() {});
    });
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/mobilenet_v1_1.0_224.tflite',
        labels: 'assets/labels.txt',
      );
    } on MissingPluginException catch (e) {
      print("MissingPluginException: ${e.message}");
    }
  }

  Future<void> classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _output = output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classifier'),
      ),
      body: Column(
        children: [
          _image == null ? Container() : Image.file(_image!),
          const SizedBox(height: 20),
          _output == null ? Text('') : Text('${_output![0]['label']}'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var image =
              await ImagePicker().pickImage(source: ImageSource.gallery);
          if (image == null) return;
          setState(() {
            _image = File(image.path);
          });
          await classifyImage(_image!);
        },
        child: const Icon(Icons.image),
      ),
    );
  }
}
