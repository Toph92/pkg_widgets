import 'package:flutter/material.dart';

/// Contrôleur pour gérer une liste animée générique.
class AnimListController<T> {
  AnimListController(
      {
      /*this.idExtractor,*/
      this.sortBy,
      this.duration = const Duration(milliseconds: 200),
      this.reverseOrder = false,
      this.separator});
  //: assert(idExtractor != null);

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final List<AnimItem<T>> items = [];
  //dynamic Function(T)? idExtractor;
  int Function(T item1, T item2)? sortBy;
  Widget Function(BuildContext context, AnimItem<T> item, AnimationType action,
      int index, bool separator)? itemBuilder;
  Widget? separator;
  final Duration duration;
  final bool reverseOrder;
  final ScrollController scrollController = ScrollController();

  void dispose() {
    scrollController.dispose();
    items.clear();
  }

  /// ajoute à la fin de la liste sans prendre en compte le tri
  void addItem(AnimItem<T> item) {
    final int index = items.length;
    items.add(item);
    listKey.currentState?.insertItem(index, duration: duration);
  }

  void insertItem(AnimItem<T> item) {
    int insertionIndex = 0;
    while (insertionIndex < items.length &&
        (reverseOrder
            ? sortBy!(items[insertionIndex].child, item.child) > 0
            : sortBy!(items[insertionIndex].child, item.child) < 0)) {
      insertionIndex++;
    }
    items.insert(insertionIndex, item);
    listKey.currentState?.insertItem(insertionIndex, duration: duration);
  }

  void removeItemByIndex(
    int index,
  ) {
    assert(itemBuilder != null);
    if (index < 0 || index >= items.length) return;
    final AnimItem<T> removedItem = items[index];
    listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: itemBuilder!(
              context, removedItem, AnimationType.remove, index, false)),
      duration: duration,
    );
    items.removeAt(index);
  }

  void removeItemById(
    dynamic id,
  ) {
    assert(itemBuilder != null);
    assert(id != null);

    int index = items.indexWhere((AnimItem item) => item.id == id);
    assert(index != -1); // pour faire planter en dev
    if (index != -1) {
      removeItemByIndex(index);
    }
  }

  void updateItemByIndex(
    int index,
    AnimItem<T> item,
  ) {
    assert(itemBuilder != null);
    if (index < 0 || index >= items.length) return;

    // Récupérer l'ancien élément
    final AnimItem<T> oldItem = items[index];

    // Supprimer l'ancien élément avec une animation
    listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: itemBuilder!(
          context,
          oldItem,
          AnimationType.update,
          index,
          false,
        ),
      ),
      duration: duration,
    );

    // Mettre à jour l'élément dans la liste locale
    items[index] = item;

    // Réinsérer le nouvel élément avec une animation
    listKey.currentState?.insertItem(
      index,
      duration: duration,
    );
  }

  void updateList(List<AnimItem<T>> newItems) {
//    assert(idExtractor != null);

    Set<dynamic> existingIds = items.map((item) => item.id).toSet();
    Set<dynamic> newIds = newItems.map((item) => item.id).toSet();

    // Trier les nouveaux éléments
    reverseOrder
        ? newItems.sort((b, a) => sortBy!(b.child, a.child))
        : newItems.sort((a, b) => sortBy!(a.child, b.child));

    // Détecter les éléments modifiés
    List<AnimItem<T>> itemsModified = [];
    for (final newItem in newItems) {
      final matchingOldItemIndex = items.indexWhere((oldItem) =>
          oldItem.id == newItem.id && oldItem.hashCode != newItem.hashCode);

      if (matchingOldItemIndex != -1) {
        final oldItem = items[matchingOldItemIndex];

        // Comparer par hashCode pour détecter une modification
        if (oldItem.hashCode != newItem.hashCode) {
          itemsModified.add(newItem);
        }
      }
    }

    // Mise à jour des éléments modifiés
    for (final modifiedItem in itemsModified) {
      final index = items.indexWhere((item) => item.id == modifiedItem.id);
      if (index != -1) {
        updateItemByIndex(index, modifiedItem);
      }
    }

    // Supprimer les éléments existants non présents dans les nouveaux
    final itemsToRemove = existingIds.difference(newIds);
    for (final id in itemsToRemove) {
      final index = items.indexWhere((item) => item.id == id);
      if (index != -1) removeItemById(id);
    }

    // Insérer les nouveaux éléments à la bonne position
    for (final AnimItem<T> newItem in newItems) {
      final dynamic newId = newItem.id;
      if (!existingIds.contains(newId)) {
        insertItem(newItem);
      }
    }
  }
}

/// Widget générique pour afficher une liste animée
class AnimList<T> extends StatelessWidget {
  final AnimListController<T> controller;

  const AnimList({
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

    controller.itemBuilder ??=
        (context, item, animationType, index, separator) {
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
      controller: controller.scrollController,
      physics: noScrollable
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      key: controller.listKey,
      initialItemCount: controller.items.length,
      itemBuilder: (context, index, animation) {
        final AnimItem<T> item = controller.items[index];
        return SizeTransition(
            sizeFactor: animation,
            child: controller.separator != null && item.separator == true
                ? Column(
                    children: [
                      controller.separator!,
                      controller.itemBuilder!(context, item,
                          AnimationType.update, index, item.separator),
                    ],
                  )
                : SizeTransition(
                    sizeFactor: animation,
                    child: controller.itemBuilder!(context, item,
                        AnimationType.update, index, item.separator)));
      },
    );
  }
}

enum AnimationType {
  insert,
  remove,
  update,
}

/* mixin ListItem {
  /* final T item;
  final int index; */
  //final AnimationType animationType;
  final bool separator = false;

  //ListItem({required this.item, required this.index, this.separator = false});
  //ListItem({this.separator = false});
} */

class AnimItem<T> {
  bool separator;
  final dynamic id;
  final T child;

  @override
  late int hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnimItem) return false;
    return id == other.id && child == other.child;
  }

  AnimItem({
    required this.id,
    required this.child,
    this.separator = false,
    int? hashCode,
  }) {
    if (hashCode != null) {
      this.hashCode = hashCode;
    } else {
      this.hashCode = this.child.hashCode;
    }
//    print("hashCode: ${this.hashCode}");
  }
}
