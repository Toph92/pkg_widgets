import 'package:flutter/material.dart';

import 'package:flutter_lorem/flutter_lorem.dart';
//import 'package:pext_completion/controler.dart';
//import 'package:pkg_text_completion/text_completion.dart';
import 'package:pkg_widgets/text_completion.dart';
import 'package:pkg_widgets/text_completion_controler.dart';

Uri apiSrv = Uri(
  scheme: 'https',
  host: 'appweb-dev.alliumfr.corp.priv',
  port: 443,
  path: '/SecurePhoneAPI/api/v1/',
);

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextCompletionControler<User> completionCtrl;
  TextEditingController prenomCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    completionCtrl = TextCompletionControler<User>(
      /*   onChangeValue: (value) {
        //print("Value=$value");
        if (value.length == 3 && value.substring(0, 3).toUpperCase() == 'DES') {
          users.add(User(lastName: 'DESBOIS', firstName: 'Isabelle'));
        }
      }, */
      /* onInputValueChanged: (value) {
        //print("Value=$value");
        if (value.length == 3 && value.substring(0, 3).toUpperCase() == 'DES') {
          users.add(User(lastName: 'DESBOIS', firstName: 'Isabelle'));
        }
      }, */
      onRequestUpdateDataSource: (arCriteria) async {
        await Future.delayed(const Duration(seconds: 1));
        return <User>[
          User(firstName: 'Christophe', lastName: 'DESBOIS'),
          User(firstName: 'Maxime', lastName: 'DESBOIS'),
        ];
      },
      //dataSource: users,

      initialListHeight: 150,
      //offsetListWidth: -40,
      minWidthList: 200,
      //maxWidthList: 400,

      onSelected: <Object>(user) {
        user = user as User;
        //print(user.firstName);
        completionCtrl.value = "${user.lastName} ${user.firstName}";
      },
    );
    completionCtrl.focusNodeTextField.addListener(refresh);
    super.initState();
  }

  @override
  void dispose() {
    completionCtrl.focusNodeTextField.removeListener(refresh);
    completionCtrl.dispose();

    super.dispose();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        backgroundColor: Colors.grey.shade300,
        body: OrientationBuilder(
            builder: (BuildContext context, Orientation direction) {
          return Column(
            // to test resizing
            children: [
              const SizedBox(
                height: 20,
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  completionCtrl.listWidth = 400;
                                },
                                child: const Text("Set size")),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  completionCtrl.close();
                                },
                                child: const Text("Close")),
                          ),
                          SizedBox(
                            //width: 300,
                            child: Form(
                              key: _formKey,
                              child: TextCompletion(
                                //focusNode: _focus,
                                needToBeSelected: false,
                                validator: (value) {
                                  value = completionCtrl.txtControler
                                      .text; // tordu cette histoire
                                  if (value.isEmpty || value.length < 3) {
                                    return 'Obligatoire (min 3 caractères)';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  hoverColor: Colors.white60,
                                  isDense: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: Theme.of(context)
                                          .primaryColor, // Change this to your desired color
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      width: 1,
                                      color: Colors
                                          .white, // Change this to your desired color
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        width: 2, color: Colors.red),
                                  ),
                                ).copyWith(
                                  labelText: "Employé",
                                  labelStyle: completionCtrl
                                          .focusNodeTextField.hasFocus
                                      ? TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).primaryColor)
                                      : completionCtrl.txtControler.text.isEmpty
                                          ? const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.grey)
                                          : TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade500,
                                            ),
                                ),
                                controler: completionCtrl,
                                minCharacterNeeded: 3,
                                txtStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                completionCtrl.dataSource?.addAll(
                                    List<User>.generate(
                                        1000,
                                        (index) => User(
                                            firstName:
                                                lorem(paragraphs: 1, words: 1),
                                            lastName:
                                                lorem(paragraphs: 1, words: 1)
                                                    .toUpperCase())));
                              },
                              child: const Text("Add 1000 users")),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  completionCtrl.value = 'coucou';
                                },
                                child: const Text("Set value")),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(width: 20, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          );
        }));
  }
}

List<User> users = [
  User(lastName: 'Père', firstName: 'Noël'),
  User(lastName: 'Père', firstName: 'Noel'),
  User(lastName: 'Père', firstName: 'NOEL'),
  User(lastName: 'Père', firstName: 'NOËL'),
  User(lastName: 'DESBOIS', firstName: 'Christophe'),
  User(lastName: 'DESBOIS', firstName: 'Maxime'),
  User(lastName: 'DAUTREMAY', firstName: 'Christelle'),
  User(lastName: 'LE DUC', firstName: 'Xenus'),
  User(lastName: 'DUPONT', firstName: 'Albert'),
  User(lastName: 'DURAND', firstName: 'Pierre-Henri'),
  User(lastName: 'DEBUS', firstName: 'Fabrice'),
  User(lastName: 'GIBOULOT', firstName: 'Xavier'),
  User(lastName: 'VEYRET', firstName: 'Pascal'),
  User(lastName: 'VEYRET', firstName: 'Maxime'),
  User(lastName: 'LEGLAND sans prénom'),
  User(lastName: 'Desbois', firstName: 'élodie'),
];

class User extends SearchEntry {
  final String? firstName;
  final String lastName;

  final String? firstNameF;
  String? lastNameF; // F comme filtred :) En majuscule sans accent en fait

  User({
    required this.lastName,
    this.firstName,
  })  : firstNameF = firstName?.removeAccents().toUpperCase(),
        lastNameF = lastName.removeAccents().toUpperCase(),
        super(
          sText: lastName + (firstName ?? ''),
        );

  @override
  String toString() {
    return "$lastName $firstName";
  }

  // add == opérator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.firstName == firstName &&
        other.lastName == lastName;
  }

  @override
  int get hashCode => firstName.hashCode ^ lastName.hashCode;

  @override
  Widget title(TextCompletionControler controler) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Row(
              children: controler.hightLightText(
            lastName,
          )),
        ),
        Expanded(
          flex: 1,
          child: Row(children: controler.hightLightText(firstName ?? '')),
        ),
      ],
    );
  }
}
