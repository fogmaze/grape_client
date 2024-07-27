import 'main.dart';
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
                  );/*ListTile(
                    title: Text(widget.tags[index]),
                    onTap: () {
                      Navigator.pop(context);
                      collectParameters.limit = widget.tags[index];
                      expandableMenuKey.currentState!.setState(() { });
                    },
                  );*/
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