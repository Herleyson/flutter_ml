import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
//import 'package:translator/translator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;

  bool isImageLoaded = false;

  String texto="";

  //final translator = new GoogleTranslator();

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future readText() async {
    texto="";
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          print(word.text);
          texto+=" "+word.text;

        }
      }
    }
    setState(() {

    });

    recognizeText.close();

  }


  Future readLabel() async {
    texto="";
    String tra="";
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    final ImageLabeler labelDetector = FirebaseVision.instance.imageLabeler();
    final List<ImageLabel> labels = await labelDetector.processImage(ourImage);


    for (ImageLabel label in labels) {


          texto+=" Conteudo: "+ label.text + "\n  id: " +label.entityId +"\n Certeza:"+ label.confidence.toString()+" \n\n";

    }

  //  texto=await translator.translate(texto, from: 'en', to: 'pt');


    setState(() {

    });
    labelDetector.close();

  }

  Future decode() async {
    texto="";
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    List barCodes = await barcodeDetector.detectInImage(ourImage);

    for (Barcode readableCode in barCodes) {
      print(readableCode.displayValue);
      texto+=" "+readableCode.displayValue;
    }
    setState(() {

    });
    barcodeDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(height: 100.0),
            isImageLoaded
                ? Center(
              child: Container(
                  height: 200.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(pickedImage), fit: BoxFit.cover))),
            )
                : Container(),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text('Escolher Imagem'),
              onPressed: pickImage,
            ),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text('Ler o Texto'),
              onPressed: readText,
            ),
            RaisedButton(
              child: Text('Ler o conteudo da imagem'),
              onPressed: readLabel,
            ),
         Flexible(
           child: ListView(
             children: <Widget>[
               Text(texto)
             ],
           ),
         )


          ],
        ));
  }
}