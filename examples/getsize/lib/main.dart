
// Fonctionne plus et ne semble pas utilisé. A supprimer ?

/* // description: Example of how to use the package to get the size of a widget
// resize the window to see the size of the container change
// Useful for Stack() widgets
//

import 'package:flutter/material.dart';
import 'package:pkg_widgets/widgets.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetGetSize<MyHomePage> {
  @override
  void initState() {
    initGetSize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(child: sizeBuilder(builder: (context, size,
                keyMain) // here i get the size of the container (stack)
            {
          double border = 16;
          size = Size(
              size.width > border ? size.width - border : size.width,
              size.height > border
                  ? size.height - border
                  : size.height); // keep place for the border
          return Stack(
            children: [
              Container(
                  key: keyMain,
                  color: Colors.amber,
                  child: const Text(
                      "Filling text to see the size of the container\nFilling text to see the size of the container\nFilling text to see the size of the containerFilling text to see the size of the container\nFilling text to see the size of the container")),
              Padding(
                padding: EdgeInsets.all(border / 2),
                child: Container(
                  // use the size of the container
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  child: const FittedBox(
                      child: Icon(
                    Icons.check_circle_sharp,
                  )),
                ),
              )
            ],
          );
        })));
  }
}
 */