import 'dart:math';

import 'package:ditredi/ditredi.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _displayMode = DisplayMode.cubes;

  final _controller =
      DiTreDiController(rotationX: 0, rotationY: 0, rotationZ: 0);

  List<Face3D>? ground;
  List<Face3D>? matureTree;
  List<Face3D>? sappling;
  List<Face3D>? youngTree;
  Future<void> fetchItem() async {
    ground = await ObjParser().loadFromResources("assets/Ground.obj");
    matureTree = await ObjParser().loadFromResources("assets/Mature-Tree.obj");
    sappling = await ObjParser().loadFromResources("assets/Sappling.obj");
    youngTree = await ObjParser().loadFromResources("assets/Young-Tree.obj");

    setState(() {});
  }

  Iterable<Model3D<Model3D<dynamic>>> _generateCubes(
      String name, List<Face3D> ground) sync* {
    int count = 20;

    for (var x = count; x > 0; x--) {
      double y = 0.0;
      double _x = x * 40;
      switch (name) {
        case "matureTree":
          y = 40;
          _x = _x - 30;
          break;
        case "youngTree":
          y = -40;
          _x = _x - 50;
          break;
        default:
      }
      yield TransformModifier3D(
          Mesh3D(ground),
          Matrix4.identity()
            ..rotateX(-0.5 * pi)
            ..translate(vector.Vector3(_x, y, 0)));
    }
  }

  @override
  void initState() {
    fetchItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      title: 'DiTreDi Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Flex(
            crossAxisAlignment: CrossAxisAlignment.start,
            direction: Axis.vertical,
            children: [
              Expanded(
                child: ground != null &&
                        matureTree != null &&
                        sappling != null &&
                        youngTree != null
                    ? DiTreDiDraggable(
                        controller: _controller,
                        child: DiTreDi(
                          figures: [
                            Line3D(vector.Vector3(0, 1, 0),
                                vector.Vector3(0, 100, 0),
                                width: 1),
                            Line3D(vector.Vector3(1, 0, 0),
                                vector.Vector3(100, 0, 0),
                                width: 1),
                            Line3D(vector.Vector3(0, 0, 1),
                                vector.Vector3(0, 0, 100),
                                width: 1),
                            ..._generateCubes("ground", ground!),
                            ..._generateCubes("matureTree", matureTree!),
                            ..._generateCubes("sappling", sappling!),
                            ..._generateCubes("youngTree", youngTree!),
                          ],
                          controller: _controller,
                        ),
                      )
                    : SizedBox(),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Drag to rotate. Scroll to zoom"),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: DisplayMode.values
                    .map((e) => Material(
                          child: InkWell(
                            onTap: () => setState(() => _displayMode = e),
                            child: ListTile(
                              title: Text(e.title),
                              leading: Radio<DisplayMode>(
                                value: e,
                                groupValue: _displayMode,
                                onChanged: (e) => setState(
                                  () => _displayMode = e ?? DisplayMode.cubes,
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DisplayMode {
  cubes,
}

extension DisplayModeTitle on DisplayMode {
  String get title {
    switch (this) {
      case DisplayMode.cubes:
        return "Cubes";
    }
  }
}
