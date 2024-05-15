import 'package:flutter/material.dart';
import 'package:image_classification/image_classifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Classification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageClassifier(),
    );
  }
}
