import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';
import 'package:flutter/material.dart';

class EnVocDef_TestingElement extends TestingElement {
  List<String>? defList;
  EnVocDef_TestingElement({required super.time});
  Future<void> init() async {;
  }
  @override
  String methodName = "en_voc_def";
  int showNum = 0;
  @override
  Widget getWidget() {
    return EnVocDef_TestingElementWidget(element: this);
  }

  @override
  void resetWidget() {
    showNum = 0;
  }

  @override
  void expandAll() {
    showNum = defList!.length;
  }
}

class EnVocDef_TestingElementWidget extends StatefulWidget {
  EnVocDef_TestingElement element;
  EnVocDef_TestingElementWidget({super.key, required this.element});
  @override
  EnVocDef_TestingElementWidgetState createState() => EnVocDef_TestingElementWidgetState();
}

class EnVocDef_TestingElementWidgetState extends State<EnVocDef_TestingElementWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.element.showNum++;
          if (widget.element.showNum > widget.element.defList!.length) {
            widget.element.showNum = 0;
          }
        });
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.22,
        child: Container(
          decoration: const BoxDecoration(),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Tap to see the definition(len:${widget.element.defList!.length})"),
                const SizedBox(height: 10),
                Text(widget.element.que, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                for (int i = 0; i < widget.element.showNum; i++)
                  Text(widget.element.defList![i], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EnVocSpe_TestingElement extends TestingElement {
  @override
  String methodName = "en_voc_spe";
  List<String>? defList;
  EnVocSpe_TestingElement({required super.time});
  @override
  Future<void> init() async {
  }
  int showNum = 1;
  double left = 0;

  @override
  Widget getWidget() {
    return EnVocSpe_TestingElementWidget(element: this);
  }

  @override
  void resetWidget() {
    showNum = 1;
    left = 0;
  }

  @override
  void expandAll() {
    showNum = defList!.length;
    left = double.infinity;
  }
}

class EnVocSpe_TestingElementWidget extends StatefulWidget {
  EnVocSpe_TestingElement element;
  EnVocSpe_TestingElementWidget({super.key, required this.element});
  @override
  EnVocSpe_TestingElementWidgetState createState() => EnVocSpe_TestingElementWidgetState();
}

class EnVocSpe_TestingElementWidgetState extends State<EnVocSpe_TestingElementWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              widget.element.showNum++;
              if (widget.element.showNum > widget.element.defList!.length) {
                widget.element.showNum = 1;
              }
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: const BoxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Spell it! click to see other definitions (len:${widget.element.defList!.length})"),
                Text(widget.element.defList!.sublist(0, widget.element.showNum).join("/"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                widget.element.left += details.delta.dx;
              });
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: widget.element.left,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.2,
                        decoration: const BoxDecoration(color: Colors.black),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(widget.element.que, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Positioned(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(widget.element.que, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]
                ),
            ),
          ),
        ),
      ],
    );
  }
}

class EnPrepDef_TestingElement extends TestingElement {
  @override
  String methodName = "en_prep_def";
  EnPrepDef_TestingElement({required super.time});

  @override
  Widget getWidget() {
    return EnPrepDef_TestingElementWidget(element: this);
  }

  @override
  void resetWidget() {
    // TODO: implement resetWidget
  }

  @override
  void expandAll() {
    // TODO: implement expandAll
  }
}

class EnPrepDef_TestingElementWidget extends StatefulWidget {
  EnPrepDef_TestingElement element;
  EnPrepDef_TestingElementWidget({super.key, required this.element});
  @override
  EnPrepDef_TestingElementWidgetState createState() => EnPrepDef_TestingElementWidgetState();
}

class EnPrepDef_TestingElementWidgetState extends State<EnPrepDef_TestingElementWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("EnPrepDef_TestingElementWidgetState");
  }
}

class EnPrepSpe_TestingElement extends TestingElement {
  EnPrepSpe_TestingElement({required super.time});
  @override
  String methodName = "en_prep_spe";

  @override
  Widget getWidget() {
    return EnPrepSpe_TestingElementWidget(element: this);
  }

  @override
  void resetWidget() {
    // TODO: implement resetWidget
  }

  @override
  void expandAll() {
    // TODO: implement expandAll
  }
}

class EnPrepSpe_TestingElementWidget extends StatefulWidget {
  EnPrepSpe_TestingElement element;
  EnPrepSpe_TestingElementWidget({super.key, required this.element});
  @override
  EnPrepSpe_TestingElementWidgetState createState() => EnPrepSpe_TestingElementWidgetState();
}

class EnPrepSpe_TestingElementWidgetState extends State<EnPrepSpe_TestingElementWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("EnPrepSpe_TestingElementWidgetState");
  }
}

class Notes_TestingElement extends TestingElement {
  TestingElement? actualElement;
  Notes_TestingElement({required super.time});
  @override
  Future<void> init() async {

  }

  @override
  String methodName = "notes";

  @override
  Widget getWidget() {
    return actualElement!.getWidget();
  }

  @override
  void resetWidget() {
    actualElement!.resetWidget();
  }

  @override
  void expandAll() {
    actualElement!.expandAll();
  }
}
