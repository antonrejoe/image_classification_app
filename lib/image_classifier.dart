import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class ImageClassifier extends StatefulWidget {
  const ImageClassifier({super.key});

  @override
  _ImageClassifierState createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<ImageClassifier> {
  File? _image;
  List? _output;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadModel().then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model.tflite',
        labels: 'assets/labels.txt',
      );
      print("Model loaded successfully");
    } catch (e) {
      print("Failed to load the model: $e");
    }
  }

  Future<void> classifyImage(File image) async {
    try {
      var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 6, // Adjust based on the number of classes
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        _output = output;
      });
    } catch (e) {
      print("Failed to classify image: $e");
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _image = File(pickedFile.path);
    });
    await classifyImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classifier'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image == null
                    ? Container()
                    : Image.file(_image!, height: 300, width: 300),
                const SizedBox(height: 20),
                _output == null
                    ? Text('No classification yet')
                    : Column(
                        children: _output!.map((result) {
                          return Text(
                            "${result['label']} - ${(result['confidence'] * 100).toStringAsFixed(2)}%",
                            style: const TextStyle(fontSize: 20),
                          );
                        }).toList(),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: const Icon(Icons.image),
      ),
    );
  }
}
