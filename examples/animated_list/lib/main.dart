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
  final int id;
  final String firstName;
  final String lastName;

  Person(
    this.id,
    this.firstName,
    this.lastName,
  );

  @override
  String toString() => 'Person(id: $id, name: $firstName $lastName)';
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
            onPressed: () =>
                _removePerson(_personController.items.indexOf(item)),
          ),
        ),
      );
    };
  }

  final AnimListController<Person> _personController =
      AnimListController<Person>(
    idExtractor: (person) => person.id.toString(),
    sortBy: (a, b) => a.firstName.compareTo(b.firstName),
    //reverseOrder: true,
    separator: Divider(color: Colors.black, thickness: 2, height: 4),
  );

  Widget Function(BuildContext, Animation<double>, Person)? itemBuilder;

  void _insert() {
    int id = 10;
    final person = Person(id, 'FirstName $id', 'LastName');
    _personController.insertItem(AnimItem(person));
  }

  void _removePerson(int index) {
    _personController.removeItem(index);
  }

  void _simulateNetworkUpdate() {
    Timer(const Duration(milliseconds: 2), () {
      List<int> randomIds = List.generate(10, (index) {
        return Random().nextInt(20);
      });
      randomIds = randomIds.toSet().toList();
      final List<AnimItem<Person>> updatedList = randomIds
          .map((id) => AnimItem(Person(id, 'FirstName $id', 'LastName')))
          .toList();

      // Mettre à jour la liste
      _personController.updateList(
        updatedList,
      );
    });
  }

  void _fillList() {
    final List<AnimItem<Person>> list = [
      AnimItem<Person>(Person(0, 'John', 'Doe')),
      AnimItem<Person>(Person(9, 'Grace', 'Black')),
      AnimItem<Person>(Person(2, 'Williams', 'Doe')),
      AnimItem<Person>(Person(3, 'Alice', 'Smith')),
      AnimItem<Person>(Person(4, 'Bob', 'Smith'), separator: true),
      AnimItem<Person>(Person(6, 'Daisy', 'Johnson')),
      AnimItem<Person>(Person(7, 'Eve', 'Jackson')),
      AnimItem<Person>(Person(8, 'Frank', 'White')),
      AnimItem<Person>(Person(10, 'Hank', 'Pym')),
      AnimItem<Person>(Person(5, 'Charlie', 'Brown')),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _insert,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'update',
            onPressed: _fillList,
            //onPressed: _simulateNetworkUpdate,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
