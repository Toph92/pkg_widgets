import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class TextCompletion extends StatefulWidget {
  const TextCompletion({
    super.key,
    required this.controller,
    this.minCharacterNeeded = 1,
    this.labelText = "",
    this.labelStyle,
    this.bgColorPopup = Colors.white,
    this.needToBeSelected = false,
    this.txtStyle,
    this.suffixDeleteIcon,
    this.onSuffixDeleteIconPressed,
    this.validator,
    required this.decoration,
  });

  final TextCompletionController controller;
  final int minCharacterNeeded;

  final String labelText;
  final TextStyle? labelStyle;
  final Color bgColorPopup;
  final TextStyle? txtStyle;
  final InputDecoration decoration;
  final Icon? suffixDeleteIcon;
  final Function()? onSuffixDeleteIconPressed;
  final String? Function(String? value)? validator;
  final bool needToBeSelected;

  //ValueNotifier<void> removeOverlay = ValueNotifier(true);

  @override
  State<TextCompletion> createState() => _TextCompletionState();
}

class _TextCompletionState extends State<TextCompletion> {
  final GlobalKey _textKey = GlobalKey();
  OverlayEntry? overlayEntry;
  final GlobalKey overlayKey = GlobalKey();
  double? textFieldWidth;
  String? hintMessage;
  double? heightTextField;
  final GlobalKey<FormFieldState<String>> _keyFormField =
      GlobalKey<FormFieldState<String>>();
  bool _hovering = false;
  bool _hasError = false;
  //List<widget.T> dataSourceFiltered = [];

  @override
  void initState() {
    assert(widget.minCharacterNeeded > 0);

    widget.controller.txtFieldNotifier.addListener(listenerOnValue);
    widget.controller.listWidthNotifier.addListener(listenerOnSetWidth);
    widget.controller.closeNotifier.addListener(listenerOnClose);

    widget.controller.txtController.text =
        widget.controller.txtFieldNotifier.value ?? '';

    widget.controller.focusNodeTextField.addListener(listenerOnFocus);
    super.initState();
  }

  void listenerOnValue() {
    widget.controller.txtController.text =
        widget.controller.txtFieldNotifier.value ?? '';
  }

  void listenerOnSetWidth() {
    if (overlayEntry != null) {
      _openOverlayPopup(key: _textKey);
    }
  }

  void listenerOnClose() {
    _closeOverlayPopup();
    widget.controller.closeNotifier.value = false;
  }

  void listenerOnFocus() {
    if (widget.controller.focusNodeTextField.hasFocus == false &&
        widget.controller.selectedFromList == false &&
        widget.controller.txtController.text.isNotEmpty) {
      if (widget.needToBeSelected) {
        hintMessage = "Sélection liste obligatoire";
        widget.controller.txtController.text = "";
      }
    } else {
      hintMessage = null;
    }
  }

  @override
  void dispose() {
    widget.controller.txtFieldNotifier.removeListener(listenerOnValue);
    widget.controller.listWidthNotifier.removeListener(listenerOnSetWidth);
    widget.controller.closeNotifier.removeListener(listenerOnClose);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _refresh(() {
        _hovering = true;
      }),
      onExit: (event) => _refresh(() {
        _hovering = false;
      }),
      // 2 layout builder, pas 1 de trop ?
      child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
        textFieldWidth = constraints.maxWidth;
        widget.controller.listWidthNotifier.value ??=
            widget.controller.getPopupListWidth(constraints.maxWidth);
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return NotificationListener<SizeChangedLayoutNotification>(
                  onNotification: (notification) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.controller.listWidthNotifier.value = widget
                          .controller
                          .getPopupListWidth(constraints.maxWidth);
                      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                      widget.controller.listWidthNotifier.notifyListeners();
                    });
                    return false;
                  },
                  child: SizeChangedLayoutNotifier(
                    child: Builder(builder: (context) {
                      return FormField(
                          initialValue: widget.controller.txtController.text,
                          autovalidateMode: AutovalidateMode.always,
                          validator: widget.validator,
                          key: _keyFormField,
                          builder: (formFieldState) {
                            _hasError = formFieldState.hasError;
                            return Stack(
                              children: [
                                TextFormField(
                                  key: _textKey,
                                  focusNode:
                                      widget.controller.focusNodeTextField,
                                  decoration: widget.decoration.copyWith(
                                      isDense: false,
                                      suffixIcon: widget.controller
                                                  .dataSourceFiltered ==
                                              null
                                          ? Transform.scale(
                                              scale: 0.7,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 4,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                              ),
                                            )
                                          : widget.controller.txtController.text
                                                      .isNotEmpty &&
                                                  (_isDesktop()
                                                      ? _hovering
                                                      : widget
                                                          .controller
                                                          .focusNodeTextField
                                                          .hasFocus)
                                              ? IconButton(
                                                  splashRadius: 1,
                                                  icon: widget
                                                          .suffixDeleteIcon ??
                                                      const Icon(Icons.clear),
                                                  onPressed: () {
                                                    widget.controller
                                                        .txtController
                                                        .clear();
                                                    widget
                                                        .onSuffixDeleteIconPressed
                                                        ?.call();
                                                    _keyFormField.currentState
                                                        ?.validate();
                                                    hintMessage = null;
                                                    _closeOverlayPopup();
                                                    widget.controller
                                                        .focusNodeTextField
                                                        .requestFocus();

                                                    if (mounted) {
                                                      _refresh();
                                                    }
                                                  },
                                                )
                                              : null),
                                  controller: widget.controller.txtController,
                                  onChanged: (value) {
                                    widget.controller.onInputValueChanged?.call(
                                        widget.controller.txtController.text);

                                    RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    heightTextField = renderBox.size.height;
                                    formFieldState.didChange(value);
                                    onChangedTxtCompletion(value);
                                  },
                                  style: widget.txtStyle,
                                ),
                                if (formFieldState.hasError)
                                  Positioned(
                                    bottom: 1,
                                    left: 10,
                                    child: Text(
                                      formFieldState.errorText!,
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                              ],
                            );
                          });
                    }),
                  ),
                );
              }),
            ),
            if (hintMessage != null && !_hasError)
              Positioned(
                  bottom: 8,
                  right: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: FittedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            hintMessage!,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      }),
    );
  }

  void onChangedTxtCompletion(String value) {
    widget.controller.selectedFromList = false;
    if (value.trim().length >= widget.minCharacterNeeded) {
      widget.controller.updateCriteria(value);
      _udpateResults();
    } else {
      _closeOverlayPopup();
      if (widget.controller.txtController.text.isNotEmpty &&
          widget.minCharacterNeeded > 0) {
        hintMessage =
            "${widget.minCharacterNeeded} caractère${widget.minCharacterNeeded > 1 ? 's' : ''} min.";
      } else {
        hintMessage = null;
      }
    }
    widget.controller.onInputValueChangedProcessed?.call(value);
    _refresh();
  }

  void _refresh([Function? f]) {
    if (mounted) {
      setState(() {
        f?.call();
      });
    } else {
      f?.call();
    }
  }

  Future<void> _udpateResults() async {
    await widget.controller.updateResultset();
    if (widget.controller.dataSourceFiltered!.isNotEmpty) {
      hintMessage = null;
      _openOverlayPopup(key: _textKey);
    } else {
      hintMessage = "Aucun résultat";
      _closeOverlayPopup();
    }
    _refresh();
  }

  void _openOverlayPopup({required GlobalKey key}) {
    RenderBox buttonRenderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    createHighlightOverlay(
      position: buttonRenderBox.localToGlobal(Offset.zero),
    );
  }

  void _closeOverlayPopup() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  void createHighlightOverlay({
    required Offset position,
  }) {
    const double borderRadius = 10;
    const double borderWidth = 1;
    const double elevation = 6;
    //print("Hello");

    // Remove the existing OverlayEntry.
    _closeOverlayPopup();

    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      // Create a new OverlayEntry.
      builder: (BuildContext context) {
        double opa = 0;
        // Align is used to position the highlight overlay
        // relative to the NavigationBar destination.
        return Positioned(
          //top: Platform.isAndroid ? position.dy + 28 : position.dy + 50,
          top: position.dy +
              (heightTextField ?? 0.0) +
              4 +
              (Platform.isAndroid ? -34.0 : 0.0),
          left: position.dx + 0,
          child: SafeArea(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width:
                    widget.controller.listWidthNotifier.value ?? textFieldWidth,
                height: widget.controller.initialListHeight ?? 100,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(elevation, elevation),
                        blurRadius: 6.0,
                      ),
                    ],
                    color: widget.bgColorPopup,
                    border: Border.all(
                      color: Colors.grey,
                      width: borderWidth,
                    ),
                    borderRadius:
                        const BorderRadius.all(Radius.circular(borderRadius))),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(borderRadius - borderWidth)),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListView.separated(
                            //shrinkWrap: true,
                            itemCount: widget.controller.dataSourceFiltered !=
                                    null
                                ? widget.controller.dataSourceFiltered!.length
                                : 0,
                            separatorBuilder: (context, index) => const Divider(
                              height: 3,
                            ),
                            itemBuilder: (context, index) {
                              return Material(
                                type: MaterialType.transparency,
                                child: ListTile(
                                    horizontalTitleGap: 4,
                                    minLeadingWidth: 0,
                                    contentPadding: const EdgeInsets.only(
                                      left: 4,
                                      right: 4,
                                    ),
                                    visualDensity: const VisualDensity(
                                        horizontal: 0, vertical: -4),
                                    dense: false,
                                    hoverColor: Colors.yellow,
                                    onTap: () {
                                      widget.controller.onSelected?.call(widget
                                          .controller
                                          .dataSourceFiltered![index]);
                                      _closeOverlayPopup();
                                      widget.controller.selectedFromList = true;
                                      hintMessage = null;
                                      _refresh();
                                    },
                                    leading: widget
                                            .controller
                                            .dataSourceFiltered![index]
                                            .fuzzySearchResult
                                        ? Icon(
                                            Icons.help,
                                            size: 24,
                                            // les ravages de l'alcool :
                                            color: Colors.blue.withOpacity(
                                                (opa = ((widget.controller.dataSourceFiltered![
                                                                        index])
                                                                    .fuzzyScore ??
                                                                1.0) *
                                                            2) >
                                                        1
                                                    ? 1
                                                    : opa),
                                          )
                                        : const SizedBox(),
                                    title: widget
                                        .controller.dataSourceFiltered![index]
                                        .title(widget.controller)),
                              );
                            },
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                      ),
                      if (widget.controller.dataSourceFiltered != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Text(
                                "${widget.controller.dataSourceFiltered!.length}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "résultat${widget.controller.dataSourceFiltered!.length > 1 ? 's' : ''}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                              if (widget.controller.dataSourceFiltered!
                                      .isNotEmpty &&
                                  widget.controller.dataSourceFiltered!.first
                                      .fuzzySearchResult) ...[
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(Icons.help,
                                    size: 16, color: Colors.blue),
                                const Text(
                                  ": recherche approchante",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey),
                                ),
                              ],
                              const Expanded(child: SizedBox()),
                              if (widget.controller.durationLastRequest !=
                                      null &&
                                  widget.controller.durationLastRequest!
                                          .inMilliseconds >
                                      20 &&
                                  Platform.isAndroid == false &&
                                  Platform.isIOS == false) ...[
                                Text(
                                  "${widget.controller.durationLastRequest!.inMilliseconds} ms",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                              ]
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    // Add the OverlayEntry to the Overlay.
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  bool _isDesktop() {
    if (kIsWeb) return false;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) return true;
    return false;
  }
}

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

class TextCompletionController<T extends SearchEntry> {
  TextCompletionController({
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
  TextEditingController txtController = TextEditingController();

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
    txtController.dispose();
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
  Widget title(TextCompletionController controller) =>
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
