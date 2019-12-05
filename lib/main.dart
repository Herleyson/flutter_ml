import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'texto.dart';

void main() => runApp(MaterialApp(
      home: MyApp2(),
    ));

class MyApp2 extends StatefulWidget {
  @override
  _MyApp2State createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  File _imagefile;
  List<Face> _faces = List<Face>();

  void detectarRosto() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector =
        FirebaseVision.instance.faceDetector(FaceDetectorOptions(
      mode: FaceDetectorMode.accurate,
      enableLandmarks: true,
    ));
    final faces = await faceDetector.processImage(image);
    if (mounted) {
      setState(() {
        _imagefile = imageFile;
        _faces = faces;
      });
    }
    faceDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("rosto"),
      ),
      body: ImageERostos(
        imageFile: _imagefile,
        face: _faces,
      ),
      floatingActionButton:Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child:FloatingActionButton(
        onPressed: detectarRosto,
        tooltip: 'Escolher imagem',
        child: Icon(Icons.photo_camera),

        )
      ),
    );
  }
}

class ImageERostos extends StatelessWidget {
  ImageERostos({this.imageFile, this.face});

  final File imageFile;
  final List<Face> face;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(
              child: imageFile == null
                  ? Text('Sem Imagem')
                  : FutureBuilder<Size>(
                      future: _getImageSize(
                          Image.file(imageFile, fit: BoxFit.fitWidth)),
                      builder:
                          (BuildContext context, AsyncSnapshot<Size> snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                              foregroundDecoration:
                               FaceDetectDecoration(
                                 face, snapshot.data),


                              child:
                                  Image.file(imageFile, fit: BoxFit.fitWidth));
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
            ))),
        Flexible(
          flex: 1,
          child: ListView(
            children: face.map<Widget>((f) => FaceCoordinates(f)).toList(),
          ),
        ),
        RaisedButton(
            padding: const EdgeInsets.fromLTRB(0.0,0.0,5.0,0.0),
            child: Text("Reconhecimento de Texto e Classificação de imagem"),
            onPressed: () {
              var route = new MaterialPageRoute(
                builder: (BuildContext context) => new MyApp(),
              );

              Navigator.of(context).pushReplacement(route);
            }),
      ],
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);

  final Face face;

  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;

    return Column(

 children: <Widget>[
   Text("Rosto Detectado"),
   ListTile(
     title: Text("(${pos.top}),(${pos.left}),(${pos.bottom}),(${pos.right})"),

   ),

 ],
    );
  }
}

class FaceDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<Face> _faces;

  FaceDetectDecoration(List<Face> faces, Size originalImageSize)
      : _faces = faces,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _FaceDetectPainter(_faces, _originalImageSize);
  }
}

class _FaceDetectPainter extends BoxPainter {
  final List<Face> _faces;
  final Size _originalImageSize;

  _FaceDetectPainter(faces, originalImageSize)
      : _faces = faces,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var face in _faces) {
      final _rect = Rect.fromLTRB(
          offset.dx + face.boundingBox.left / _widthRatio,
          offset.dy + face.boundingBox.top / _heightRatio,
          offset.dx + face.boundingBox.right / _widthRatio,
          offset.dy + face.boundingBox.bottom / _heightRatio);
      canvas.drawRect(_rect, paint);
    }
    canvas.restore();
  }
}

Future<Size> _getImageSize(Image image) {
  Completer<Size> completer = Completer<Size>();
  image.image.resolve(ImageConfiguration()).addListener(
    ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      },
    ),
  );
  return completer.future;
}


