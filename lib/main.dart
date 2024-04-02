import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import "package:http/http.dart" as http;
import 'package:expandable_widgets/expandable_widgets.dart';
import 'fileSync.dart';
import 'Methods.dart';
import 'package:network_info_plus/network_info_plus.dart';

var baseUrl = "http://localhost:8000/";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "Yeah",),
    );
  }
}

MainTestArea mainTestArea = MainTestArea();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  void handleChangeLimitInput(String value) {
    setState(() {
      // TODO implement this
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Text("$nowTestingElementIdx / ${testingElements.length}"),
          Positioned(
            left: mainTestArea.posLeft * MediaQuery.of(context).size.width,
            top: mainTestArea.posTop * MediaQuery.of(context).size.height,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  mainTestArea.handleDragUpdateGesture(details, context);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  mainTestArea.handleDragEndGesture(details);
                });
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.75,
                  child: Column(
                    children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.018),
                      child: mainTestArea.relatedSingleTestingArea.getWidget(),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:mainTestArea.mainSingleTestingArea.getWidget(),
                    ),
                    ],
                  )
                )
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Stack(
              children: <Widget>[
                ExpandableMenuWidget()
            ]),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isServerOn = !isServerOn;
            if (isServerOn) {
              var wifiInfo = NetworkInfo();
              wifiInfo.getWifiIP().then((value) {
                Fluttertoast.showToast(
                    msg: "Server started at $value:8765",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 5,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              });
              startServer().then((value) {
                server = value;
              });
            } else {
              Fluttertoast.showToast(
                  msg: "Server stopped",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              stopServer(server!);
            }
          });
        },
        tooltip: 'Increment',
        child: isServerOn? const Icon(Icons.wifi_off): const Icon(Icons.wifi),
      ),
    );
  }
}

class ExpandableMenuWidget extends StatefulWidget {
  const ExpandableMenuWidget({super.key});
  @override
  State<StatefulWidget> createState() => _ExpandableMenuWidgetState();
}

class _ExpandableMenuWidgetState extends State<ExpandableMenuWidget> {


  @override
  Widget build(BuildContext context) {
    return Expandable(
        firstChild: Text("Limit: ${collectParameters.getLimit()}"),
        subChild: const Text("change parameters"),
        secondChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0,),
          child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("Limit: "),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          onSubmitted: (String value) {
                            setState(() {
                              collectParameters.handleLimitInput(value);
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter new limit',
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Load previous: "),
                      Switch(
                        value: collectParameters.loadPrevious,
                        onChanged: (bool value) {
                          setState(() {
                            collectParameters.loadPrevious = value;
                          });
                        },
                      ),
                    ]),
                const Text("Method: "),
                CheckboxListTile(
                  title: const Text("en_voc_def"),
                  value: collectParameters.methods.contains("en_voc_def"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        collectParameters.methods.add("en_voc_def");
                      } else {
                        collectParameters.methods.remove("en_voc_def");
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("en_voc_spe"),
                  value: collectParameters.methods.contains("en_voc_spe"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        collectParameters.methods.add("en_voc_spe");
                      } else {
                        collectParameters.methods.remove("en_voc_spe");
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("en_prep_def"),
                  value: collectParameters.methods.contains("en_prep_def"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        collectParameters.methods.add("en_prep_def");
                      } else {
                        collectParameters.methods.remove("en_prep_def");
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("en_prep_spe"),
                  value: collectParameters.methods.contains("en_prep_spe"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        collectParameters.methods.add("en_prep_spe");
                      } else {
                        collectParameters.methods.remove("en_prep_spe");
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("notes"),
                  value: collectParameters.methods.contains("notes"),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        collectParameters.methods.add("notes");
                      } else {
                        collectParameters.methods.remove("notes");
                      }
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      reGet();
                    });
                  },
                  child: const Text("Reget"),
                ),
              ]
          ),
        )
    );
  }
}

class CollectParameters {
  Future<void> initFromDB() async{
  }
  Future<void> save2DB() async{
  }
  int minLevel = -1;
  String limit = "0";
  String limitCode = "";
  bool loadPrevious = false;
  List<String> methods = [];
  String getLimit() {
    // TODO implement this
    return limit;
  }

  List<dynamic> sorted(List list) {
    list.sort();
    return list;
  }
  void handleLimitInput(String value) {
    limit = value;
    String ret = '(';
    sorted(value.split("|")).forEach((element) {
      sorted(element.split("&")).forEach((element) {
        ret += 'tags like "%|$element|%" and ';
      });
      ret = ret.substring(0, ret.length - 4);
      ret += ') or (';
    });
    ret = ret.substring(0, ret.length - 5);
    limitCode = ret;
  }
}

abstract class TestingElement {
  int time;
  String que = "";
  String ans = "";
  String testingBlacklist = "";
  String tags = "";
  TestingElement({required this.time});
  void regetRelatedTestingElements() async {
    relatedElements = await getRelatedTestingElements(this, );
  }

  Future<void> initialUpdate(String tableName) async {
  }
  abstract String methodName;
  GestureDetector? detector;
  List<TestingElement>? relatedElements;

  Future<void> init() async {}

  void resetWidget();
  void expandAll();
  Widget getWidget();
}

class DefaultTestingElement extends TestingElement {
  @override
  String methodName = "Default";
  var idx = 0;
  DefaultTestingElement({this.idx = 0, bool isMain=true, required super.time}){
    if (isMain) {
      relatedElements = [
        DefaultTestingElement(idx: 1, isMain: false, time: 0,),
        DefaultTestingElement(idx: 2, isMain: false, time: 0)
      ];
    }
  }
  @override
  Widget getWidget() {
    return DefaultTestingElementWidget(idx: idx);
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

class SingleTestingArea {
  SingleTestingArea();
  TestingElement element = DefaultTestingElement(time: 0);
  void updateElement(TestingElement element) {
    this.element = element;
  }
  Widget getWidget() => SingleTestingAreaWidget(element: element);
}

class SingleTestingAreaWidget extends StatefulWidget {
  const SingleTestingAreaWidget({super.key, required this.element});
  final TestingElement element;
  @override
  State<StatefulWidget> createState() => _SingleTestingAreaWidgetState();
}

class _SingleTestingAreaWidgetState extends State<SingleTestingAreaWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.72,
          height: MediaQuery.of(context).size.height * 0.33,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row( // TODO implement tool
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("from: ${widget.element.tags}", style: const TextStyle(fontSize: 16)),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          widget.element.expandAll();
                        });
                      },
                      icon: const Icon(Icons.lightbulb),
                    )
                  ],
                ),
                const Divider(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.22,
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: widget.element.getWidget()
                ),
              ],
            )
          )
        ),
      ),
    );
  }
}

class MainTestArea {
  SingleTestingArea relatedSingleTestingArea = SingleTestingArea();
  SingleTestingArea mainSingleTestingArea = SingleTestingArea();
  var posLeft = 0.1;
  var posTop = 0.08;

  void updateTestingElement() {
    mainSingleTestingArea.updateElement(testingElements[nowTestingElementIdx]);
    if (testingElements[nowTestingElementIdx].relatedElements != null) {
      relatedSingleTestingArea.updateElement(testingElements[nowTestingElementIdx].relatedElements![0]);
    }
    relatedSingleTestingArea.updateElement(DefaultTestingElement(time: 0));
  }
  void handleDragUpdateGesture(DragUpdateDetails details, BuildContext context) {
    posLeft += details.delta.dx / MediaQuery.of(context).size.width;
    posTop += details.delta.dy / MediaQuery.of(context).size.height;
  }
  void handleDragEndGesture(DragEndDetails details) {
    bool change = false;
    TestingElement? e;
    if (posLeft < 0.0) {;
      change = true;
    }
    else if (testingElements[nowTestingElementIdx].methodName == "notes" && posLeft > 0.2) {
      e = testingElements.removeAt(nowTestingElementIdx);
      nowTestingElementIdx--;
      change = true;
    }
    else if (posTop > 0.1) {
      change = true;
    }
    posLeft = 0.1;
    posTop = 0.08;
    if (change) {
      change2NextTestingElement();

    }
  }
}


Future<void> takeNote() async {
  if (testingElements[nowTestingElementIdx].methodName == "notes") {
    return ;
  }
  Fluttertoast.showToast(
      msg: "Note taken",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM_LEFT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

Future<void> removeFromNote(TestingElement element) async {
  if (element.methodName == "notes") {
    Notes_TestingElement e = element as Notes_TestingElement;
    Fluttertoast.showToast(
        msg: "Note removed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_LEFT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}

Future<void> saveRemain2DB() async {

}

void change2NextTestingElement() {
  if (nowTestingElementIdx < testingElements.length - 1) {
    nowTestingElementIdx++;
  } else {
    // shuffle the testing List
    testingElements.shuffle(Random());
    nowTestingElementIdx = 0;
    for (var e in testingElements) {
      e.resetWidget();
    }
  }
  mainTestArea.updateTestingElement();
}

Future<List<TestingElement>> getRelatedTestingElements(TestingElement element) async {
  List<TestingElement>? ret;
  List<Map<String, dynamic>> result;
  if (element.methodName.contains("voc")) {
    if (element.methodName.contains("def")) {
    }
  }
  else {
    ret = [DefaultTestingElement(time: 0)];
  }
  if (ret == null) {
    return [DefaultTestingElement(time: 0)];
  }
  for (var e in ret) {
  }
  return ret;
}

Future<int> initLoading() async {
  List<Map<String, dynamic>> matchedId = [{'id': 0}];
  if (matchedId.isEmpty) {
    Fluttertoast.showToast(
        msg: "No previous record found",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    await reGet();
    int? id = 0;
    return id!;
  }
  else {
    int id = matchedId[0]['id'];
    Fluttertoast.showToast(
        msg: "Previous record found with id: $id",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  return 0;
}

Future<TestingElement> getTestingElementFromMethodTime(String method, int time) async{
  late TestingElement ret;
  if (method == "en_voc_def") {
    ret = EnVocDef_TestingElement(time: time);
  }
  else if (method == "en_voc_spe") {
    ret = EnVocSpe_TestingElement(time: time);
  }
  else if (method == "en_prep_def") {
    ret = EnPrepDef_TestingElement(time: time);
  }
  else if (method == "en_prep_spe") {
    ret = EnPrepSpe_TestingElement(time: time);
  }
  else if (method == "notes") {
    ret = Notes_TestingElement(time: time);
  }
  else {
    ret = DefaultTestingElement(time: time);
  }
  return ret;
}

Future<void> reGet() async{
  var requestStr = "$baseUrl?type=reget&method_name=${collectParameters.methods.join("^")}&tags=${collectParameters.limit}&isLoad=${collectParameters.loadPrevious}";
  var response = await http.get(Uri.parse(requestStr));
  if (response.statusCode == 200) {
    var data = response.body;
    print(data);
  }
  else {
    Fluttertoast.showToast(
        msg: "Bad response when reget",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}

CollectParameters collectParameters = CollectParameters();
var nowTestingElementIdx = 0;
var nowId = 0;
List<TestingElement> testingElements = [DefaultTestingElement(idx: 8, time: 0), DefaultTestingElement(time: 0), DefaultTestingElement(idx: 22, time: 0)];
bool isServerOn = false;
HttpServer? server;
Map<String, String> methodName2Table = {
  "en_voc_def": "en_voc",
  "en_voc_spe": "en_voc",
  "en_prep_def": "en_prep",
  "en_prep_spe": "en_prep",
  "notes": "notes"
};