import 'package:flutter/material.dart';
import 'package:pkg_widgets/titleborderbox.dart';
import 'dart:math';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:pkg_widgets/dialogs.dart';

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
  // Clés pour référencer les widgets et obtenir leur position
  final GlobalKey _btnAddKey = GlobalKey();
  final GlobalKey _btnMenuKey = GlobalKey();

  // Méthode pour afficher un menu contextuel à la position d'un widget
  void _showMenuAtButton(BuildContext context, GlobalKey buttonKey) {
    final RenderBox button =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    // Calcule la position du menu par rapport au bouton
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        offset,
        offset.translate(button.size.width, button.size.height),
      ),
      Offset.zero & MediaQuery.of(context).size,
    );

    showMenu(
      context: context,
      position: position,
      items: <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.recycling, size: 24),
              SizedBox(width: 8),
              Text("Supprimer les valeurs"),
            ],
          ),
        ),
        //PopupMenuDivider(),
        PopupMenuItem<int>(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.recycling, size: 24, color: Colors.orange),
              SizedBox(width: 8),
              Text("Supprimer les critères"),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        // Action en fonction de l'option sélectionnée
        switch (value) {
          case 1:
            if (context.mounted) {
              DialogCust<bool>(
                context: context,
                message: 'Pas fait 😵‍💫',
              ).ok();
            }
            break;
          case 2:
            setState(() {
              itemsClients.clear();
            });
            break;
        }
      }
    });
  }

  // Utilisation du package DialogCust pour afficher un dialogue personnalisé

  void _addClient() {
    setState(() {
      itemsClients.add(
        GroupItem(
          lorem(
            words:
                Random().nextInt(5) +
                1, // Génère un texte aléatoire de 1 à 2 mots
            paragraphs: 1,
          ),
          genererCouleurAleatoire(),
        ),
      );
    });
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
      backgroundColor: Colors.grey[200], // Couleur de fond personnalisée
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              'Exemple de TitleBorderBox',
              style: TextStyle(fontSize: 25, color: Colors.grey.shade700),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TitleBorderBox(
                      title: 'Clients',
                      titleStyle: TitleBorderBox.none().titleStyle!.copyWith(
                        color: Colors.blue,
                        fontSize: 20,
                      ),
                      borderColor: Colors.blue,
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: IconButton.filled(
                                    tooltip: "Ajouter",
                                    key: _btnAddKey,
                                    onPressed: () {
                                      _addClient();
                                    },
                                    icon: Icon(Icons.add),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      minimumSize: Size(30, 30),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (itemsClients.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: IconButton.filled(
                                      key: _btnMenuKey,
                                      tooltip: "Supprimer ...",
                                      onPressed: () {
                                        _showMenuAtButton(context, _btnMenuKey);
                                      },
                                      icon: Icon(Icons.recycling),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        minimumSize: Size(30, 30),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (itemsClients.isNotEmpty)
                              VerticalDivider(
                                color: Colors.grey,
                                thickness: 1,
                                width: 4,
                              ),

                            Expanded(
                              child:
                                  itemsClients.isNotEmpty
                                      ? Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        spacing: 4,
                                        runSpacing: 4,
                                        children:
                                            itemsClients
                                                .map(
                                                  (item) => Container(
                                                    color: item.color,
                                                    child: Text(item.name),
                                                  ),
                                                )
                                                .toList(),
                                      )
                                      : Text(
                                        "Ajouter un élément",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TitleBorderBox(
                      title: 'Fournisseurs',
                      borderColor: Colors.blue,
                      child: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            itemsFournisseurs
                                .map(
                                  (item) => Container(
                                    color: item.color,
                                    child: Text(item.name),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClient,
        tooltip: 'Ajouter un client',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupItem {
  String name;
  Color color;
  GroupItem(this.name, this.color);
}

List<GroupItem> itemsClients = List.generate(10, (index) {
  return GroupItem(
    lorem(
      words: Random().nextInt(5) + 1, // Génère un texte aléatoire de 1 à 2 mots
      paragraphs: 1,
    ), // Génère un texte aléatoire de 2 mots
    genererCouleurAleatoire(), // Génère une couleur aléatoire
  );
});

List<GroupItem> itemsFournisseurs = List.generate(20, (index) {
  return GroupItem(
    lorem(
      words: Random().nextInt(5) + 1, // Génère un texte aléatoire de 1 à 2 mots
      paragraphs: 1,
    ), // Génère un texte aléatoire de 2 mots
    genererCouleurAleatoire(), // Génère une couleur aléatoire
  );
});

Color genererCouleurAleatoire() {
  final random = Random();
  return Color.fromRGBO(
    random.nextInt(256), // Rouge (0-255)
    random.nextInt(256), // Vert (0-255)
    random.nextInt(256), // Bleu (0-255)
    1.0, // Opacité (1.0 = complètement opaque)
  );
}
