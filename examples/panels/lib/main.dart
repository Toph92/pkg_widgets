import 'package:flutter/material.dart';
import 'package:pkg_widgets/panels/panels.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Panels panels = Panels();

  @override
  void initState() {
    super.initState();
    panels.list.add(Panel(
        width: 500,
        child: Container(
            color: Colors.amber,
            child: Center(
                child: Text('Container 1',
                    style: TextStyle(color: Colors.black))))));
    panels.list.add(Panel(
        width: 200,
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
              color: Colors.green,
              child: Center(
                  child: FittedBox(
                child: Column(
                  children: [
                    Text('Container 2', style: TextStyle(color: Colors.black)),
                    Text('${constraints.maxWidth}',
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              )));
        })));
    panels.list.add(Panel(
        width: 500,
        child: Container(
            color: Colors.blue,
            child: Center(
                child: Text('Container 3',
                    style: TextStyle(color: Colors.white))))));
    panels.list.add(Panel(
        width: 500,
        child: Container(
            color: Colors.red,
            child: Center(
                child: Text('Container 4',
                    style: TextStyle(color: Colors.black))))));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Synchronized Responsive Layout'),
        ),
        body: HMultiPanels(
          panels: panels,
        ),
      ),
    );
  }
}
