import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';
import 'package:flutter/material.dart';

class EnVocDef_TestingElement extends TestingElement {
  List<String>? defList;

  EnVocDef_TestingElement({required super.dataObject});
  @override
  void init() {
    initialUpdate();
    defList = ans.split("|");
    defList!.shuffle(Random());
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

  @override
  Future<void> onShow() async {
    if (activateTTS) {
      await flutterTts?.speak(que);
    }
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
        height: MediaQuery.of(context).size.height * 0.55,
        child: Container(
          decoration: const BoxDecoration(),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text("Tap to see the definition"),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () async {
                          await widget.element.ttsInstance?.speak(widget.element.que);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(widget.element.que, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                for (int i = 0; i < widget.element.showNum; i++)
                  Text(widget.element.defList![i], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                for (int i = widget.element.showNum; i < widget.element.defList!.length; i++)
                  const Text("...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
  EnVocSpe_TestingElement({required super.dataObject});
  @override
  void init() {
    initialUpdate();
    defList = ans.split("|");
    defList!.shuffle(Random());
    hint = getHint(que);
  }
  int showNum = 1;
  double left = 0;
  bool isShowHint = false;
  String hint = "";
  bool isSpoken = false;


  @override
  Widget getWidget() {
    return EnVocSpe_TestingElementWidget(element: this);
  }

  @override
  void resetWidget() {
    showNum = 1;
    left = 0;
    isShowHint = false;
    isSpoken = false;
  }

  @override
  void expandAll() {
    showNum = defList!.length;
    left = double.infinity;
    if (activateTTS && !isSpoken) {
      flutterTts?.speak(que);
      isSpoken = true;
    }
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
                const Text("Spell it! click to see other definitions"),
                Text(widget.element.defList!.sublist(0, widget.element.showNum).join("/") + "/..." * (widget.element.defList!.length - widget.element.showNum), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        if (widget.element.isShowHint)
          Text(widget.element.hint, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                widget.element.left += details.delta.dx;
              });
            },
            onTap: () {
              setState(() {
                if (!widget.element.isShowHint) {
                  widget.element.isShowHint = true;
                }
                else {
                  widget.element.expandAll();
                }
              });
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(widget.element.que, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(
                      left: widget.element.left,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.55,
                        decoration: const BoxDecoration(color: Colors.black),
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
  EnPrepDef_TestingElement({required super.dataObject});

  @override
  void init() {

  }

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
  EnPrepSpe_TestingElement({required super.dataObject});
  @override
  String methodName = "en_prep_spe";

  @override
  void init() {

  }

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
  Notes_TestingElement({required super.dataObject});
  @override
  void init() {
    actualElement = getTestingElementFromObject(dataObject["actual"]);
    time = dataObject["time"];
    tags = actualElement!.tags;
    isNoted = true;
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
class DefaultTestingElement extends TestingElement {
  @override
  String methodName = "Default";
  var idx = 0;
  DefaultTestingElement({this.idx = 0, bool isMain=true, required super.dataObject}){
    if (isMain) {
      relatedElements = [
        DefaultTestingElement(idx: 1, isMain: false, dataObject: null,),
        DefaultTestingElement(idx: 2, isMain: false, dataObject: null)
      ];
    }
  }
  @override
  Widget getWidget() {
    return DefaultTestingElementWidget(idx: idx);
  }

  @override
  void resetWidget() {
  }

  @override
  void expandAll() {
  }

  @override
  void init() {
  }
}

class DefaultTestingElementWidget extends StatefulWidget {
  const DefaultTestingElementWidget({super.key, this.idx = 0});
  final int idx;
  @override
  State<StatefulWidget> createState() => _DefaultTestingElementWidgetState();
}

class _DefaultTestingElementWidgetState extends State<DefaultTestingElementWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("DefaultTestingElement${widget.idx}");
  }
}

String getHint(String ans) {
  var words = ans.split(" ");
  var processedWords = [];
  for (var word in words) {
    if (word.length > 3) {
      processedWords.add(word[0] + "*" * (word.length - 2) + word[word.length - 1]);
    } else {
      processedWords.add("*" * word.length);
    }
  }
  return processedWords.join(" ");
}
