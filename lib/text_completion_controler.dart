import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart' show kIsWeb;
//import 'dart:io';

class CacheItem<T> {
  CacheItem({required this.key, required this.value});
  final String key;
  final List<T> value;

  // add == operator and hashCode to compare CacheItem
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CacheItem) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

class CacheManager<T> {
  CacheManager({this.maxSize = 100}) {
    assert(maxSize > 0);
  }

  int maxSize;
  List<CacheItem> cache = [];

  void add(CacheItem item) {
    if (get(item.key) != null) {
      return;
    }
    cache.add(item);
    if (cache.length > maxSize) {
      cache.removeAt(0);
    }
  }

  List<T>? get(String key) {
    for (CacheItem item in cache) {
      if (item.key == key) {
        return item.value as List<T>;
      }
    }
    return null;
  }

  bool isNotEmpty() {
    return cache.isNotEmpty;
  }

  List<T> get fullContent {
    List<T> result = [];
    for (CacheItem item in cache) {
      result.addAll(item.value as List<T>);
    }
    // uniq in result
    result = result.toSet().toList();
    return result;
  }
}

class TextCompletionControler<T extends SearchEntry> {
  TextCompletionControler({
    this.dataSource,
    this.onRequestUpdateDataSource,
    this.fuzzySearch = true,
    this.onSelected,
    String? initialValue,
    double? initialListWidth,
    this.initialListHeight,
    this.minWidthList,
    this.maxWidthList,
    this.offsetListWidth = 0,
    this.onInputValueChangedProcessed,
    this.onInputValueChanged,
  }) {
    assert(
        (dataSource == null && onRequestUpdateDataSource != null) ||
            (dataSource != null && onRequestUpdateDataSource == null),
        "Cannot have both dataSource and onRequestUpdateDataSource");
    assert(dataSource != null || onRequestUpdateDataSource != null,
        "You must provide a dataSource or a onRequestUpdateDataSource function");
    txtFieldNotifier.value = initialValue;
    focusNodeTextField.addListener(onFocused);
  }

  List<T>? dataSource;
  CacheManager<T> cacheManager = CacheManager(maxSize: 100);
  int nbBestFuzzy = 3; // nombre de résultats flous à afficher
  List<String>? _arCriteria;
  bool fuzzySearch;
  bool selectedFromList = false; // true if selected in list
  TextEditingController txtControler = TextEditingController();

  /// set text value to TextField
  set value(String value) {
    txtFieldNotifier.value = value;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    txtFieldNotifier.notifyListeners();
    // sinon pas de refresh si sélection de la même valeur dans la liste.
  }

  close() {
    closeNotifier.value = true;

    /* // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    closeNotifier.notifyListeners();
    // sinon pas de refresh si sélection de la même valeur dans la liste. */
  }

  // Valeur saisie après traitement
  Function(String value)? onInputValueChangedProcessed;

  // Valeur saisie avant traitement
  Function(String value)? onInputValueChanged;

  // callback to update data from parent
  Future<List<T>?> Function(List<String>? arCriteria)?
      onRequestUpdateDataSource;

  List<T>? dataSourceFiltered =
      []; // null: runing search, []: no result, else: result

  set listWidth(double value) {
    listWidthNotifier.value = value;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    listWidthNotifier.notifyListeners();
    // sinon pas de refresh si sélection de la même valeur dans la liste.
  }

  double? minWidthList;
  double? maxWidthList;

  /// width offset regarding text field width. Can be negative or positive
  double offsetListWidth;

  double? initialListHeight;
  final FocusNode focusNodeTextField = FocusNode();

  ValueNotifier<String?> txtFieldNotifier = ValueNotifier(null);
  ValueNotifier<double?> listWidthNotifier = ValueNotifier(null);
  ValueNotifier<bool> closeNotifier = ValueNotifier(false);

  Duration? durationLastRequest;

  /// return selected item in [value]
  Function<T>(dynamic value)? onSelected;
  // bof, j'étais parti sur Function(T value)? onUpdate; mais cela ne marche pas au niveau du call()
  // Il veut absolument déclarer le type avant la function.
  // et lors de l'appel un <Object> fait l'affaire. Ca sent le bug ou moi qui merde quelque part :(

  onFocused() {
    if (focusNodeTextField.hasFocus == false) {
      // pour laisser le temps au clic sur la liste de fonctionner
      Future.delayed(const Duration(milliseconds: 100)).then(
        (value) {
          close();
        },
      );
    }
  }

  void dispose() {
    txtFieldNotifier.dispose();
    listWidthNotifier.dispose();
    closeNotifier.dispose();
    txtControler.dispose();
    onSelected = null;
    focusNodeTextField.removeListener(onFocused);
    focusNodeTextField.dispose();
  }

  updateCriteria(String? criteria) {
    criteria ??= "";
    List<String> chunks = criteria
        .removeAccents()
        .toUpperCase()
        .replaceAll(RegExp('\\s+'), ' ')
        .split(' ');
    chunks.removeWhere((element) => element == ' ' || element == '');
    chunks = Set<String>.from(chunks).toList();
    _arCriteria = chunks;
  }

  Future<void> updateResultset() async {
    final stopwatch = Stopwatch()..start();
    durationLastRequest = null;
    dataSourceFiltered = null;
    if (onRequestUpdateDataSource != null) {
      dataSource = cacheManager.get(_arCriteria!.join(''));
      dataSource ??= await onRequestUpdateDataSource!(_arCriteria);
      if (dataSource != null && dataSource!.isNotEmpty) {
        cacheManager
            .add(CacheItem<T>(key: _arCriteria!.join(''), value: dataSource!));
      }
    }
    assert(dataSource != null); // si null , c'est qu'il y a un problème

    dataSourceFiltered = dataSource!
        .where((element) => ((element).sText).containsAll(_arCriteria ?? []))
        .toList();
    dataSourceFiltered?.forEach((element) {
      (element).fuzzySearchResult = false;
    });

    if (dataSourceFiltered!.isEmpty &&
        fuzzySearch &&
        cacheManager.isNotEmpty()) {
      List<T>? bestUsers = getNearestEntries(
          arCriteria: _arCriteria!,
          dataSource: cacheManager.isNotEmpty()
              ? cacheManager.fullContent
              : dataSource!);

      dataSourceFiltered!.addAll(bestUsers);
    }
    durationLastRequest = stopwatch.elapsed;
  }

  List<T> getNearestEntries(
      {required List<String> arCriteria, required List<T> dataSource}) {
    List<T> bestFuzzySearch = [];

    SearchEntry entry = SearchEntry(sText: arCriteria.join(''));

    int occu = 0;

    for (T element in dataSource) {
      //assert(element is SearchEntry);
      occu = 0;
      if ((element).qB2.isNotEmpty) {
        occu = (entry.qB2.toSet().intersection(element.qB2.toSet())).length;
      }
      if ((element).qB3.isNotEmpty) {
        occu += (entry.qB3.toSet().intersection(element.qB3.toSet())).length;
      }
      (element).fuzzyOccu = occu;
      if (occu > 0) {
        element.fuzzyScore = (occu / (entry.qB2.length + entry.qB3.length));
      } else {
        element.fuzzyScore = 0;
      }
      if (element.fuzzyScore! > 0 /* && element.fuzzySearchResult == null */) {
        element.fuzzySearchResult = true;
        bestFuzzySearch.add(element);
        bestFuzzySearch
            .sort((a, b) => (b).fuzzyOccu!.compareTo((a).fuzzyOccu!));
        if (bestFuzzySearch.length > nbBestFuzzy) {
          bestFuzzySearch.removeLast();
        }
      }
    }
    return bestFuzzySearch;
  }

  /// SPLIT [source] in function of [arChunk]
  List<String> splitText(String source, List<String> arChunk) {
    List<String> result = [];

    if (arChunk.isEmpty) {
      result.add(source);
      return result;
    }
    List<String> arChunkTmp = List<String>.from(arChunk);

    arChunkTmp.sort((a, b) => source.indexOf(a).compareTo(source.indexOf(b)));

    int start = 0;

    for (String chunk in arChunkTmp) {
      int index = source
          .removeAccents()
          .toUpperCase()
          .indexOf(chunk.removeAccents().toUpperCase(), start);

      if (index != -1) {
        result.add(source.substring(start, index));
        result.add(source.substring(index, index + chunk.length));
        start = index + chunk.length;
      }
    }

    if (start < source.length && source.substring(start) != '') {
      result.add(source.substring(start));
    }

    if (result.isNotEmpty && result[0] == '') {
      result.removeAt(0);
    }

    return result;
  }

  /// return array of Text() to fill Row()
  List<Widget> hightLightText(String source) {
    List<Widget> results = [];
    _arCriteria ??= [];

    List<String> arTmp = splitText(source, _arCriteria!);
    _arCriteria = _arCriteria!
        .map((element) => element.removeAccents().toUpperCase())
        .toList();

    for (var element in arTmp) {
      if (_arCriteria!.contains(element.removeAccents().toUpperCase())) {
        results.add(Text(
          element,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              backgroundColor: getBgColor(
                  _arCriteria!.indexOf(element.removeAccents().toUpperCase()))),
        ));
      } else {
        results.add(Text(
          element,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ));
      }
    }
    return results;
  }

  List<Color> colorsBackground = [
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.brown.shade300,
    Colors.pink.shade200,
    Colors.orange.shade300,
    Colors.teal.shade200,
    Colors.grey.shade400,
    Colors.lightGreen.shade500,
    Colors.cyan.shade200,
    Colors.lime.shade500,
    Colors.blueGrey.shade200,
    Colors.yellow.shade500,
  ];

  Color getBgColor(int indice) {
    return colorsBackground[indice % colorsBackground.length];
  }

  double getPopupListWidth(double textFieldWidth) {
    double result = textFieldWidth + offsetListWidth;
    if (minWidthList != null && result < minWidthList!) result = minWidthList!;
    if (maxWidthList != null && result > maxWidthList!) result = maxWidthList!;
    return result;
  }
}

class SearchEntry {
  Widget title(TextCompletionControler controler) =>
      const Text("to be overridden");

  late String sText;
  List<String> qB2 = [];
  List<String> qB3 = [];
  bool fuzzySearchResult =
      false; // true si c'est resultat de recherche approximative, false sinon. null si pas de recherche
  int?
      fuzzyOccu; // le nombre d'occurences trouvée, plus c'est elevé, plus c'est approchant. Sinon si non recherche approx
  double? fuzzyScore; // le pourcentage de résultat occu/occu des critères

  SearchEntry({required String sText}) {
    this.sText = sText.replaceAll(' ', '').removeAccents().toUpperCase();
    qB2 = _quickBlock(this.sText, 2);
    qB3 = _quickBlock(this.sText, 3);
  }

  List<String> _quickBlock(String input, int n) {
    List<String> result = [];

    for (int i = 0; i < input.length - n + 1; i++) {
      result.add(input.substring(i, i + n));
    }
    return result;
  }
}

extension RemoveAccentsExtension on String {
  String removeAccents() {
    return replaceAll(RegExp(r'[àáâãäå]', caseSensitive: true), 'a')
        .replaceAll(RegExp(r'[èéêë]', caseSensitive: true), 'e')
        .replaceAll(RegExp(r'[ìíîï]', caseSensitive: true), 'i')
        .replaceAll(RegExp(r'[òóôõö]', caseSensitive: true), 'o')
        .replaceAll(RegExp(r'[ùúûü]', caseSensitive: true), 'u')
        .replaceAll(RegExp(r'[ýÿ]', caseSensitive: true), 'y')
        .replaceAll(RegExp(r'[ÀÁÂÃÄÅ]', caseSensitive: true), 'A')
        .replaceAll(RegExp(r'[ÈÉÊË]', caseSensitive: true), 'E')
        .replaceAll(RegExp(r'[ÌÍÎÏ]', caseSensitive: true), 'I')
        .replaceAll(RegExp(r'[ÒÓÔÕÖ]', caseSensitive: true), 'O')
        .replaceAll(RegExp(r'[ÙÚÛÜ]', caseSensitive: true), 'U')
        .replaceAll(RegExp(r'[Ý]', caseSensitive: true), 'Y');
  }

  bool containsAny(List<String> keywords) {
    return keywords.any((keyword) => contains(keyword));
  }

  bool containsAll(List<String> keywords) {
    return keywords.every((keyword) => contains(keyword));
  }
}
