import 'package:flutter/material.dart';
import 'package:pkg_widgets/panels.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  PanelsController panelsController = PanelsController();

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    panelsController.list.add(Panel(
        width: 200,
        sizable: 0,
        child: Container(
            color: Colors.amber,
            child: Center(
                child: FittedBox(
              child: Column(
                children: [
                  Text('Menu Fixe', style: TextStyle(color: Colors.black)),
                  TextButton(
                      onPressed: () {
                        panelsController.setVisiblity(index: 0, visible: false);
                      },
                      child: Text("Cacher"))
                ],
              ),
            )))));
    panelsController.list.add(Panel(
        width: 500,
        sizable: 100,
        noHide: true,
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
              color: Colors.green,
              child: Center(
                  child: FittedBox(
                child: Column(
                  children: [
                    Text('Container Sizable',
                        style: TextStyle(color: Colors.black)),
                    Text('${constraints.maxWidth}',
                        style: TextStyle(color: Colors.black)),
                    TextButton(
                        onPressed: () {
                          panelsController.setVisiblity(
                              index: 1, visible: false);
                        },
                        child: Text("Cacher"))
                  ],
                ),
              )));
        })));
    panelsController.list.add(Panel(
        width: 500,
        sizable: 0,
        visible: false,
        child: Container(
            color: Colors.blue,
            child: Center(
                child: Text('Container Fixe',
                    style: TextStyle(color: Colors.white))))));
    /* panelsController.list.add(Panel(
        width: 500,
        child: Container(
            color: Colors.red,
            child: Center(
                child: Text('Container 4',
                    style: TextStyle(color: Colors.black)))))); */
    /* panelsController.setSeparator(
        width: 4,
        separator: const VerticalDivider(
          width: 4,
          thickness: 2,
          color: Colors.blue,
        )); */
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Synchronized Responsive Layout'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 4,
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    spacing: 20,
                    children:
                        List.generate(panelsController.list.length, (index) {
                      int panelId = index + 1;
                      return Row(
                        children: [
                          Text(
                            "Panel $panelId",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Switch(
                            value: panelsController.isVisible(index),
                            onChanged: (value) {
                              panelsController.setVisiblity(
                                  index: index, visible: value);
                              _refresh();
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            Flexible(
              child: HMultiPanels(
                panels: panelsController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
