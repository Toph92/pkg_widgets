import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pkg_widgets/anim_list.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PersonListExample(),
    );
  }
}

class Person {
  final String firstName;
  final String lastName;

  Person(
    this.firstName,
    this.lastName,
  );

  @override
  String toString() => 'Person(name: $firstName $lastName)';
}

/// Exemple concret avec des objets Person
class PersonListExample extends StatefulWidget {
  const PersonListExample({super.key});

  @override
  PersonListExampleState createState() => PersonListExampleState();
}

class PersonListExampleState extends State<PersonListExample> {
  PersonListExampleState() {
    _personController.itemBuilder =
        (context, item, AnimationType animation, int index, bool separator) {
      return Card(
        color: animation == AnimationType.remove
            ? Colors.red
            : (index.isEven ? Colors.blue.shade600 : Colors.blue),
        child: ListTile(
          title: Text('${item.child.firstName} ${item.child.lastName}',
              style: const TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _removePerson(item.id),
          ),
        ),
      );
    };
  }

  final AnimListController<Person> _personController =
      AnimListController<Person>(
    //idExtractor: (person) => person.id.toString(),
    sortBy: (a, b) => a.firstName.compareTo(b.firstName),
    //reverseOrder: true,
    separator: Divider(color: Colors.black, thickness: 2, height: 4),
  );

  Widget Function(BuildContext, Animation<double>, Person)? itemBuilder;

  void _insert() {
    int id = 10;
    final person = Person('FirstName $id', 'LastName');
    _personController.insertItem(AnimItem(id: id, child: person));
  }

  void _removePerson(int id) {
    _personController.removeItemById(id);
  }

  void _simulateNetworkUpdate() {
    Timer(const Duration(milliseconds: 2), () {
      List<int> randomIds = List.generate(10, (index) {
        return Random().nextInt(20);
      });
      randomIds = randomIds.toSet().toList();
      final List<AnimItem<Person>> updatedList = randomIds
          .map((id) =>
              AnimItem(id: id, child: Person('FirstName $id', 'LastName')))
          .toList();

      // Mettre à jour la liste
      _personController.updateList(
        updatedList,
      );
    });
  }

  void _fillList() {
    final List<AnimItem<Person>> list = [
      AnimItem<Person>(id: 20, child: Person('John', 'Doe')),
      AnimItem<Person>(id: 9, child: Person('Grace', 'Black')),
      AnimItem<Person>(id: 2, child: Person('Williams', 'Doe')),
      AnimItem<Person>(id: 3, child: Person('Alice', 'Smith')),
      AnimItem<Person>(id: 4, child: Person('Bob', 'Smith'), separator: true),
      AnimItem<Person>(id: 6, child: Person('Daisy', 'Johnson')),
      AnimItem<Person>(id: 7, child: Person('Eve', 'Jackson')),
      AnimItem<Person>(id: 8, child: Person('Frank', 'White')),
      AnimItem<Person>(id: 10, child: Person('Hank', 'Pym')),
      AnimItem<Person>(id: 5, child: Person('Charlie', 'Brown')),
    ];
    _personController.updateList(list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Personnes')),
      body: AnimList<Person>(
        controller: _personController,
      ),
      floatingActionButton: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _insert,
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            heroTag: 'update',
            onPressed: _fillList,
            //onPressed: _simulateNetworkUpdate,
            child: const Icon(Icons.refresh),
          ),
          FloatingActionButton(
            heroTag: 'rnd',
            onPressed: _simulateNetworkUpdate,
            child: const Icon(Icons.shuffle),
          ),
        ],
      ),
    );
  }
}
