import 'package:flutter/material.dart';
import "package:pkg_widgets/chipDate.dart";
import "package:pkg_widgets/chipText.dart";
import "package:pkg_widgets/chipCommon.dart";

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

class _MyHomePageState extends State<MyHomePage> {
  ChipTextController userController = ChipTextController();
  ChipTextController hourController = ChipTextController();
  ChipDateController dateController = ChipDateController();
  TextEditingController textController = TextEditingController();
  bool bHeureVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Wrap(
          //direction: Axis.vertical,
          //alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(textController.text),
            ),
            SizedBox(
                width: 100,
                child: TextField(
                  controller: textController,
                  onChanged: (value) {
                    setState(() {});
                  },
                )),
            const SizedBox(height: 30, child: VerticalDivider()),
            Text(userController.textValue ?? '?'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: NotificationListener(
                onNotification: (notification) {
                  switch (notification.runtimeType) {
                    case ChipUpdateNotification _:
                      /* debugPrint(
                          "Notif: ${(notification as ChipUpdateNotification).value}"); */
                      debugPrint("value=${userController.textValue}");

                      setState(() {});
                      break;
                    case ChipDeleteNotification _:
                      debugPrint("Delete");
                      //utilisateur.visible = false;

                      break;
                    default:
                  }
                  return true;
                },
                child: ChipText(
                  controller: userController,
                  bgColor: Colors.blue.shade200,
                  emptyMessage: "Utilisateur ?",
                  tooltipMessageEmpty: "Saisir une partie du nom ou du prénom",
                  tooltipMessage: "Utilisateur",
                  removable: true,
                  textFieldWidth: 150,
                  bottomMessage: "Utilisateur",
                  disabledColor: Colors.blueGrey,
                ),
              ),
            ),
            if (bHeureVisible)
              NotificationListener<ChipDeleteNotification>(
                onNotification: (notification) {
                  setState(() {
                    bHeureVisible = false;
                  });

                  return true;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChipText(
                    controller: hourController,
                    bgColor: Colors.orange.shade200,
                    removable: true,
                    emptyMessage: "Heure ?",
                    textFieldWidth: 100,
                    icon: Icons.alarm,
                  ),
                ),
              ),
            NotificationListener(
                onNotification: (notification) {
                  switch (notification.runtimeType) {
                    case ChipUpdateNotification _:
                      /*debugPrint(
                          "Notif: ${(notification as ChipUpdateNotification).value}");*/
                      debugPrint("value=${dateController.dateValue}");
                      break;
                    case ChipDeleteNotification _:
                      debugPrint("Delete");
                      //dateDebut.visible = false;
                      break;
                    default:
                  }
                  return true;
                },
                child: ChipDate(
                  controller: dateController,
                  bgColor: Colors.lightGreen,
                  emptyMessage: "Date début ?",
                  bottomMessage: "Date début",
                  icon: Icons.calendar_month_outlined,
                  removable: false,
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  //utilisateur.visible = true;
                  //dateDebut.visible = true;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.visibility_off),
                onPressed: () {
                  //utilisateur.visible = false;
                },
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    userController.textValue = "Hello";
                    dateController.dateValue =
                        DateTime.now().add(const Duration(days: 2));
                  },
                  child: const Text("Set Value"),
                ))
          ],
        ),
      ),
    );
  }
}
