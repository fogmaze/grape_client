import 'dart:convert';

import 'main.dart';
import 'selectTagFromHistory.dart';
import 'package:flutter/material.dart';

class TagSelectPage extends StatefulWidget {
  TagSelectPage({super.key, required this.tags});

  final List<String> tags;
  final List<String> selectedTags = [];

  @override
  TagSelectPageState createState() => TagSelectPageState();

}

class TagSelectPageState extends State<TagSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Tag"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          collectParameters.limit = widget.selectedTags.join("|");
          Navigator.pop(context);
          expandableMenuKey.currentState!.setState(() { });
        },
        child: const Icon(Icons.check_circle),
      ),
      body: Center(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              sliver: SliverToBoxAdapter(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      getFromHost({
                        "type": "getRecordHistory",
                        "account": collectParameters.account,
                      }).then(
                        (value) {
                          var json = jsonDecode(value.body);
                          if (json["status"] != "success") {
                            return;
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryTagSelectPage(data: json["data"])));
                        }
                      );
                    });
                  },
                  child: const Text("From history"),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: widget.selectedTags.contains(widget.tags[index]) ? Theme.of(context).colorScheme.onPrimary: Theme.of(context).colorScheme.onSecondary,
                    ),
                    child: CheckboxListTile(
                      title: Text(widget.tags[index], style: TextStyle(fontWeight: widget.selectedTags.contains(widget.tags[index]) ? FontWeight.bold : FontWeight.normal)),
                      value: widget.selectedTags.contains(widget.tags[index]),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            widget.selectedTags.add(widget.tags[index]);
                          } else {
                            widget.selectedTags.remove(widget.tags[index]);
                          }
                        });
                      },
                      activeColor: Colors.blue
                    ),
                  );
                },
                childCount: widget.tags.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}