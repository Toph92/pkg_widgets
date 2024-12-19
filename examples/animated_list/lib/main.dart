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

class Person extends ListItem {
  final int id;
  final String firstName;
  final String lastName;

  Person(this.id, this.firstName, this.lastName, {super.separator = false});

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
        (context, person, AnimationType animation, int index, bool separator) {
      return Card(
        color: animation == AnimationType.remove
            ? Colors.red
            : (index.isEven ? Colors.blue.shade600 : Colors.blue),
        child: ListTile(
          title: Text('${person.firstName} ${person.lastName}',
              style: const TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () =>
                _removePerson(_personController.items.indexOf(person)),
          ),
        ),
      );
    };
  }

  final GenericAnimatedListController<Person> _personController =
      GenericAnimatedListController<Person>(
    idExtractor: (person) => person.id.toString(),
    //stringExtractor: (person) => person.id.toString(),
    sortBy: (a, b) => a.firstName.compareTo(b.firstName),
    reverseOrder: true,
    separator: Divider(color: Colors.black, thickness: 2, height: 4),
  );

  Widget Function(BuildContext, Animation<double>, Person)? itemBuilder;

  void _insert() {
    int id = 10;
    final person = Person(id, 'FirstName $id', 'LastName');
    _personController.insertItem(person);
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
      final updatedList = randomIds
          .map((id) => Person(id, 'FirstName $id', 'LastName'))
          .toList();

      // Mettre à jour la liste
      _personController.updateList(
        updatedList,
      );
    });
  }

  void _fillList() {
    final List<Person> list = [
      Person(1, 'John', 'Doe'),
      Person(9, 'Grace', 'Black'),
      Person(2, 'Williams', 'Doe'),
      Person(3, 'Alice', 'Smith'),
      Person(4, 'Bob', 'Smith', separator: true),
      Person(6, 'Daisy', 'Johnson'),
      Person(7, 'Eve', 'Jackson'),
      Person(8, 'Frank', 'White'),
      Person(10, 'Hank', 'Pym'),
      Person(5, 'Charlie', 'Brown'),
      /*     Person(11, 'Ivy', 'Green'),
      Person(12, 'Jack', 'Black'),
      Person(13, 'Karen', 'White'),
      Person(14, 'Leo', 'King'),
      Person(15, 'Mona', 'Lisa'),
      Person(16, 'Nina', 'Brown'),
      Person(17, 'Oscar', 'Wilde'),
      Person(18, 'Paul', 'Walker'),
      Person(19, 'Quinn', 'Carter'),
      Person(20, 'Rose', 'Tyler'), */
    ];
    _personController.updateList(list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Personnes')),
      body: GenericAnimatedList<Person>(
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
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
