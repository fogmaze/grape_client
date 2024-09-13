import 'main.dart';
import 'package:flutter/material.dart';

class HistoryTagSelectPage extends StatefulWidget {
  const HistoryTagSelectPage({super.key, required this.data});

  final dynamic data;

  @override
  HistoryTagSelectPageState createState() => HistoryTagSelectPageState();

}

class HistoryTagSelectPageState extends State<HistoryTagSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Tag"),
      ),
      body: Center(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color:Theme.of(context).colorScheme.onSecondary,
                    ),
                    child: ListTile(
                      title: Text("[${widget.data[index][1]}] ${widget.data[index][2]}"),
                      onTap: () {
                        collectParameters.limit = widget.data[index][2];
                        collectParameters.methods.clear();
                        var methodsTmp = widget.data[index][1].split("|");
                        for (var e in methodsTmp) {
                          if (e != "") {
                            collectParameters.methods.add(e);
                          }
                        }
                        Navigator.pop(context);
                        expandableMenuKey.currentState!.setState(() { });
                      },
                    ),
                  );
                },
                childCount: widget.data.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
