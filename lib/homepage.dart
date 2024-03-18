import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _image;

  //
  Future<void> getImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? selectedSource = await _showImageSourceOptions(context);
    // final XFile? image =
    //     await picker.pickImage(source: _showImageSourceOptions(context));
    if (selectedSource != null) {
      final XFile? image = await picker.pickImage(source: selectedSource);

      if (image != null) {
        ImageCropper imageCropper = ImageCropper();
        final croppedImage = await imageCropper
            .cropImage(sourcePath: image.path, aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ], uiSettings: [
          IOSUiSettings(
            title: 'Cropper',
          )
        ]);
        setState(() {
          _image = croppedImage != null ? XFile(croppedImage.path) : null;
        });
      }
    }
  }

  _openCamera() {
    if (_image == null) {
      getImageFromCamera();
    }
  }

  Future<ImageSource> _showImageSourceOptions(BuildContext context) async {
    ImageSource? selectedSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Select Image Source",
          style: TextStyle(fontSize: 22, color: Colors.blue),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text("Camera"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            )
          ],
        ),
      ),
    );

    return selectedSource ?? ImageSource.gallery;
  }

  // Future<ImageSource> _showImageSourceOptions(BuildContext context) async {
  //   ImageSource? selectedSource = await showDialog<ImageSource>(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //             title: const Text("Select Image Source"),
  //             content: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 ElevatedButton(
  //                   onPressed: () => Navigator.pop(context, ImageSource.camera),
  //                   child: const Text("Camera"),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 ElevatedButton(
  //                   onPressed: () =>
  //                       Navigator.pop(context, ImageSource.gallery),
  //                   child: const Text('Gallery'),
  //                 )
  //               ],
  //             ),
  //           ));
  // }
  Future<void> sendImage(XFile? imagefile) async {
    if (imagefile == null) return;
    String base64Image = base64Encode(File(imagefile.path).readAsBytesSync());
    String apikey = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text(
            'GemeniMaths',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _openCamera();
          },
          tooltip: _image == null ? 'Pick Image' : 'send image',
          child: Icon(
            _image == null ? Icons.camera_alt : Icons.send,
            color: Colors.grey.shade900,
          ),
        ),
        body: Stack(
          children: [
            _image == null
                ? const Center(
                    child: Text(
                      'Welcome to GemeniMaths',
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  )
                : Image.file(File(_image!.path))
          ],
        ));
  }
}
