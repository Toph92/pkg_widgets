import 'package:flutter/material.dart';
import 'WidgetGetSize.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
  /* var key = GlobalKey();  
  Size? redboxSize;  
  double width = 0;  
  double height = 0;
  
  postFrameCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        redboxSize = getRedBoxSize(key.currentContext!);
      });
    });
  }
 */
  @override
  void initState() {
    super.initState();
    initGetSize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Coucou") //Text(widget.title),
            ),
        body: Center(
            child: Container(
          color: Colors.red,
          child: sizeBuilder((context, size, key) {
            return Stack(
              children: [
                Container(
                    key: key,
                    color: Colors.amber,
                    child: const Text(
                        "Ah que coucou\ncoucou coucou coucou\ncoucou coucou coucou\ncoucou coucou coucou coucou coucou coucou\ncoucou coucou coucou coucou coucou coucou\ncoucou coucou coucou coucou coucou coucou\ncoucou coucou coucou coucou coucou coucou")),
                /*  Icon(Icons.check_circle_sharp,
                    size: size.height < size.width ? size.height : size.width)*/
                Container(
                  color: Colors.green.withOpacity(0.5),
                  width: size.width,
                  height: size.height,
                )
              ],
            );
          }),
        )));
  }
}

/* Size getRedBoxSize(BuildContext context) {
  final box = context.findRenderObject() as RenderBox;
  return box.size;
} */
