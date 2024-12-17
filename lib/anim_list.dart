import 'package:flutter/material.dart';

/// Contrôleur pour gérer une liste animée générique
class GenericAnimatedListController<T> {
  GenericAnimatedListController(
      {this.idExtractor,
      this.sortBy,
      this.duration = const Duration(milliseconds: 200),
      this.reverseOrder = false})
      : assert(idExtractor != null);

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final List<T> items = [];
  dynamic Function(T)? idExtractor;
  int Function(T item1, T item2)? sortBy;
  Widget Function(
          BuildContext context, T item, AnimationType action, int index)?
      itemBuilder;
  final Duration duration;
  final bool reverseOrder;

  void dispose() {
    items.clear();
  }

  /// ajoute à la fin de la liste sans prendre en compte le tri
  void addItem(T item) {
    final int index = items.length;
    items.add(item);
    listKey.currentState?.insertItem(index, duration: duration);
  }

  void insertItem(T item) {
    int insertionIndex = 0;
    while (insertionIndex < items.length &&
        (reverseOrder
            ? sortBy!(items[insertionIndex], item) > 0
            : sortBy!(items[insertionIndex], item) < 0)) {
      insertionIndex++;
    }
    items.insert(insertionIndex, item);
    listKey.currentState?.insertItem(insertionIndex, duration: duration);
  }

  void removeItem(
    int index,
  ) {
    assert(itemBuilder != null);
    if (index < 0 || index >= items.length) return;
    final T removedItem = items[index];
    listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
          sizeFactor: animation,
          child:
              itemBuilder!(context, removedItem, AnimationType.remove, index)),
      duration: duration,
    );
    items.removeAt(index);
  }

  void updateList(List<T> newItems) {
    Set<dynamic> existingIds = items.map(idExtractor!).toSet();
    Set<dynamic> newIds = newItems.map(idExtractor!).toSet();

    // Trier les nouveaux éléments
    reverseOrder
        ? newItems.sort((b, a) => sortBy!(b, a))
        : newItems.sort((a, b) => sortBy!(a, b));

    // Supprimer les éléments existants non présents dans les nouveaux
    final itemsToRemove = existingIds.difference(newIds);
    for (final id in itemsToRemove) {
      final index = items.indexWhere((item) => idExtractor!(item) == id);
      if (index != -1) removeItem(index);
    }

    // Insérer les nouveaux éléments à la bonne position
    for (final T newItem in newItems) {
      final dynamic newId = idExtractor!(newItem);
      if (!existingIds.contains(newId)) {
        insertItem(newItem);
      }
    }
  }
}

/// Widget générique pour afficher une liste animée
class GenericAnimatedList<T> extends StatelessWidget {
  final GenericAnimatedListController<T> controller;

  const GenericAnimatedList({
    super.key,
    required this.controller,

    /// Si on veut que la liste prenne la taille de son contenu
    this.shrinkWrap = false,

    /// Si on ne veut pas de scroll
    this.noScrollable = false,
  });

  final bool shrinkWrap;
  final bool noScrollable;

  @override
  Widget build(BuildContext context) {
    assert(controller.itemBuilder != null);

    controller.itemBuilder ??= (context, item, animationType, index) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: 50,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Center(child: Text("Missing itemBuilder"))),
      );
    };
    return AnimatedList(
      physics: noScrollable
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      key: controller.listKey,
      initialItemCount: controller.items.length,
      itemBuilder: (context, index, animation) {
        final T item = controller.items[index];
        return SizeTransition(
            sizeFactor: animation,
            child: controller.itemBuilder!(
                context, item, AnimationType.update, index));
      },
    );
  }
}

enum AnimationType {
  insert,
  remove,
  update,
}
