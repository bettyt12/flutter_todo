import 'package:flutter/material.dart';
import 'package:flutter_todo/constants/colors.dart';
import 'package:flutter_todo/model/todo.dart';
import 'package:flutter_todo/widgets/todo_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  File? _image;

  @override
  void initState() {
    _foundToDo = todosList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 30, bottom: 20),
                        child: Text(
                          "All To Dos",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      for (ToDo todoo in _foundToDo.reversed)
                        TodoItem(
                          todo: todoo,
                          onToDoChanged: _handleToDOChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                        hintText: "Add new to do item",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    child: Text('+', style: TextStyle(fontSize: 40)),
                    onPressed: () {
                      _addToDoItem(_todoController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      // primary: tdBlue,
                      minimumSize: Size(50, 50),
                      elevation: 10,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: _getImageFromCamera,
                    child: Text(
                      'Take a Picture',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDOChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(ToDo todo) {
    setState(() {
      todosList.removeWhere((element) => element.id == todo.id);
    });
  }

  void _addToDoItem(String todo) {
    setState(() {
      todosList.add(ToDo(
          id: DateTime.now().millisecondsSinceEpoch.toString(), todoText: todo));
    });
    _todoController.clear();
  }

  void _searchToDoItem(String searchText) {
    setState(() {
      List<ToDo> results = [];
      if (searchText.isEmpty) {
        results = todosList;
      } else {
        results = todosList
            .where((item) => item.todoText!.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
      setState(() {
        _foundToDo = results;
      });
    });
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _searchToDoItem(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(Icons.search, color: tdgrey, size: 20),
          prefixIconConstraints: BoxConstraints(maxHeight: 30, maxWidth: 35),
          border: InputBorder.none,
          hintText: "Search",
          hintStyle: TextStyle(color: tdgrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Icon(Icons.menu,color: tdBlack, size: 30),
        Container(height: 40,width: 40,child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child:Image.asset('assets/images/constructionworker.png') ),)
      ],),
    );
  }

  
  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      // Call function to process the image with the model
      _processImage(_image);
    }
  }

  // Future<void> _processImage(File? image) async {
  //   // Implement logic to process the image using the model
  //   // For YOLOv5 model, you need to pass the image through the model
  //   // and get the predicted objects along with their labels
  //   // Once processed, you can display the results or take further actions

  //    // Pick an image from the device's gallery
  // final picker = ImagePicker();
  // final pickedFile = await picker.getImage(source: ImageSource.gallery);

  // if (pickedFile != null) {
  //   // Read the picked image file
  //   File imageFile = File(pickedFile.path);

  //   // Preprocess the image
  //   img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
  //   image = img.copyResize(image, width: 416, height: 416); // Resize to 416x416

  //   // Convert the resized image into a tensor
  //   List<int> inputValues = image.getBytes();
  //   var inputTensor = inputValues.map((e) => e / 255.0).toList(); // Normalize pixel values

  //   // Run inference on the preprocessed image using the YOLOv5 model
  //   try {
  //     List<dynamic>? recognitions = await Tflite.detectObjectOnBinary(
  //       binary: Uint8List.fromList(image.getBytes()),
  //       model: 'YOLOv5', // Load YOLOv5 model
  //       threshold: 0.5, // Confidence threshold
  //       imageHeight: image.height,
  //       imageWidth: image.width,
  //     );

  //     // Process the output predictions
  //     if (recognitions != null && recognitions.isNotEmpty) {
  //       // Handle the detections
  //       for (final detection in recognitions) {
  //         // Process each detection
  //         print('Class: ${detection['label']}');
  //         print('Confidence: ${detection['confidence']}');
  //         print('Bounding box: ${detection['rect']}');
  //       }
  //     } else {
  //       print('No objects detected');
  //     }
  //   } catch (e) {
  //     print('Error running inference: $e');
  //   }
  // } else {
  //   print('No image selected');
  // }
  // }
  Future<void> _processImage(File? image) async {
  // Load the TFLite model from assets
  try {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/model.labels',
    );
  } catch (e) {
    print('Error loading model: $e');
    return;
  }

  // Pick an image from the device's gallery
  final picker = ImagePicker();
  final pickedFile = await picker.getImage(source: ImageSource.gallery);
 print(" get image 292");
  if (pickedFile != null) {
    // Read the picked image file
    File imageFile = File(pickedFile.path);
 print("image line 296");
    // Preprocess the image
    img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
    image = img.copyResize(image, width: 416, height: 416); // Resize to 416x416
 print("image resize 300");
    // Convert the resized image into a tensor
    List<int> inputValues = image.getBytes();
    var inputTensor = inputValues.map((e) => e / 255.0).toList(); // Normalize pixel values
print("image in byte");
    // Run inference on the preprocessed image using the YOLOv5 model
    try {
      List<dynamic>? recognitions = await Tflite.detectObjectOnBinary(
        binary: Uint8List.fromList(image.getBytes()),
        threshold: 0.5, // Confidence threshold
      );
      print("try catch");
      // Process the output predictions
      if (recognitions != null && recognitions.isNotEmpty) {
        // Handle the detections
        print("hello");
        for (final detection in recognitions) {
          // Process each detection
          print('Class: ${detection['label']}');
          print('Confidence: ${detection['confidence']}');
          print('Bounding box: ${detection['rect']}');
        }
      } else {
        print('No objects detected');
      }
    } catch (e) {
      print('Error running inference: $e');
    }
  } else {
    print('No image selected');
  }

  // Dispose the TFLite model after use
  // Tflite.close();
}
}