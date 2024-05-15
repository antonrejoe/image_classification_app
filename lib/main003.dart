import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  bool _loading = false;
  List<dynamic>? _output;
  final _picker = ImagePicker();

  pickImage() async {
    var image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      return null;
    }

    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  pickGalleryImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return null;
    }

    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      // setState(() {});
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  classifyImage(File? image) async {
    var output = await Tflite.runModelOnImage(
      path: image!.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _output = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/mobilenet_v1_1.0_224.tflite.tflite',
      labels: 'assets/labels.txt',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat vs Dog Classifier'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 160.0),
            _image == null
                ? Text('No image selected')
                : Container(
                    child: Image.file(_image!),
                    height: 250.0, // Fixed height for image
                  ),
            SizedBox(height: 20.0),
            _output != null ? Text('${_output![0]['label']}') : Container(),
            SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Take Picture'),
            ),
            ElevatedButton(
              onPressed: pickGalleryImage,
              child: Text('Camera Roll'),
            ),
          ],
        ),
      ),
    );
  }
}
