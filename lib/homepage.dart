import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _image;
  String _responseBody = '';
  bool isSending = false;
  String customprompt = '';
  final TextEditingController _controller = TextEditingController();

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
    setState(() {
      isSending = true;
    });
    if (imagefile == null) return;
    String base64Image = base64Encode(File(imagefile.path).readAsBytesSync());
    String apikey = "AIzaSyBrh2f1QdgeaFFuwzKB73gj-LE5-_Qoxl8";
    String requestBody = json.encode({
      "contents": [
        {
          "parts": [
            {
              "text": customprompt == " "
                  ? "Solve this maths function and write step by step details and the reason behind the step"
                  : customprompt
            },
            {
              "inlineData": {"mimeType": "image/jpeg", "data": base64Image}
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.4,
        "topK": 32,
        "topP": 1,
        "maxOutputTokens": 4096,
        "stopSequences": []
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ]
    });
    http.Response response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro-vision-latest:generateContent?key=$apikey ",
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonBody = json.decode(response.body);
      setState(() {
        _responseBody =
            jsonBody["candidates"][0]["content"]["parts"][0]["text"];
        isSending = false;
      });
      print(response.body);
      print("Image sent successfully");
    } else {
      setState(() {
        isSending = false;
      });
    }
    print("Failed to send image");
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
            _image == null ? _openCamera() : sendImage(_image);
          },
          tooltip: _image == null ? 'Pick Image' : 'send image',
          child: Icon(
            _image == null ? Icons.camera_alt : Icons.send,
            color: Colors.grey.shade900,
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
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
                      : Image.file(
                          File(_image!.path),
                        ),
                  const SizedBox(
                    height: 18,
                  ),
                  TextField(
                    controller: _controller,
                    onChanged: (value) {
                      customprompt = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Enter your custom prompt",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      _responseBody,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
            if (isSending)
              const Center(
                  child: const CircularProgressIndicator(
                color: Colors.blue,
              ))
          ],
        ));
  }
}


// '{
//   "contents": [
//     {
//       "parts": [
//         {
//           "text": "describ ehat you see"
//         },
//         {
//           "inlineData": {
//             "mimeType": "image/jpeg",
//             "data": "'$(base64 -w0 image0.jpeg)'"
//           }
//         }
//       ]
//     }
//   ],
//   "generationConfig": {
//     "temperature": 0.4,
//     "topK": 32,
//     "topP": 1,
//     "maxOutputTokens": 4096,
//     "stopSequences": []
//   },
//   "safetySettings": [
//     {
//       "category": "HARM_CATEGORY_HARASSMENT",
//       "threshold": "BLOCK_MEDIUM_AND_ABOVE"
//     },
//     {
//       "category": "HARM_CATEGORY_HATE_SPEECH",
//       "threshold": "BLOCK_MEDIUM_AND_ABOVE"
//     },
//     {
//       "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
//       "threshold": "BLOCK_MEDIUM_AND_ABOVE"
//     },
//     {
//       "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
//       "threshold": "BLOCK_MEDIUM_AND_ABOVE"
//     }
//   ]
// }'