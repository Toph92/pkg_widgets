import 'package:flutter/material.dart';
import 'text_completion_controler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class TextCompletion extends StatefulWidget {
  const TextCompletion({
    super.key,
    required this.controler,
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

  final TextCompletionControler controler;
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
  final GlobalKey textKey = GlobalKey();
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

    widget.controler.txtFieldNotifier.addListener(listenerOnValue);
    widget.controler.listWidthNotifier.addListener(listenerOnSetWidth);
    widget.controler.closeNotifier.addListener(listenerOnClose);

    widget.controler.txtControler.text =
        widget.controler.txtFieldNotifier.value ?? '';

    widget.controler.focusNodeTextField.addListener(listenerOnFocus);
    super.initState();
  }

  void listenerOnValue() {
    widget.controler.txtControler.text =
        widget.controler.txtFieldNotifier.value ?? '';
  }

  void listenerOnSetWidth() {
    if (overlayEntry != null) {
      showPopup(key: textKey);
    }
  }

  void listenerOnClose() {
    removeHighlightOverlay();
    widget.controler.closeNotifier.value = false;
  }

  void listenerOnFocus() {
    if (widget.controler.focusNodeTextField.hasFocus == false &&
        widget.controler.selectedFromList == false &&
        widget.controler.txtControler.text.isNotEmpty) {
      if (widget.needToBeSelected) {
        hintMessage = "Sélection liste obligatoire";
        widget.controler.txtControler.text = "";
      }
    } else {
      hintMessage = null;
    }
  }

  @override
  void dispose() {
    widget.controler.txtFieldNotifier.removeListener(listenerOnValue);
    widget.controler.listWidthNotifier.removeListener(listenerOnSetWidth);
    widget.controler.closeNotifier.removeListener(listenerOnClose);
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
        widget.controler.listWidthNotifier.value ??=
            widget.controler.getPopupListWidth(constraints.maxWidth);
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return NotificationListener<SizeChangedLayoutNotification>(
                  onNotification: (notification) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.controler.listWidthNotifier.value = widget
                          .controler
                          .getPopupListWidth(constraints.maxWidth);
                      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                      widget.controler.listWidthNotifier.notifyListeners();
                    });
                    return false;
                  },
                  child: SizeChangedLayoutNotifier(
                    child: Builder(builder: (context) {
                      return FormField(
                          initialValue: widget.controler.txtControler.text,
                          autovalidateMode: AutovalidateMode.always,
                          validator: widget.validator,
                          key: _keyFormField,
                          builder: (formFieldState) {
                            _hasError = formFieldState.hasError;
                            return Stack(
                              children: [
                                TextFormField(
                                  key: textKey,
                                  focusNode:
                                      widget.controler.focusNodeTextField,
                                  decoration: widget.decoration.copyWith(
                                      isDense: false,
                                      suffixIcon: widget.controler
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
                                          : widget.controler.txtControler.text
                                                      .isNotEmpty &&
                                                  (_isDesktop()
                                                      ? _hovering
                                                      : widget
                                                          .controler
                                                          .focusNodeTextField
                                                          .hasFocus)
                                              ? IconButton(
                                                  splashRadius: 1,
                                                  icon: widget
                                                          .suffixDeleteIcon ??
                                                      const Icon(Icons.clear),
                                                  onPressed: () {
                                                    widget
                                                        .controler.txtControler
                                                        .clear();
                                                    widget
                                                        .onSuffixDeleteIconPressed
                                                        ?.call();
                                                    _keyFormField.currentState
                                                        ?.validate();
                                                    hintMessage = null;
                                                    removeHighlightOverlay();

                                                    if (mounted) {
                                                      _refresh();
                                                    }
                                                  },
                                                )
                                              : null),
                                  controller: widget.controler.txtControler,
                                  onChanged: (value) {
                                    widget.controler.onInputValueChanged?.call(
                                        widget.controler.txtControler.text);

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

  /* void onChangedTxtCompletion(String value) {
    widget.controler.selectedFromList = false;
    if (value.trim().length >= widget.minCharacterNeeded) {
      widget.controler.updateCriteria(value);
      if (widget.controler.dataSourceFiltered2!.isNotEmpty) {
        hintMessage = null;
        showPopup(key: textKey);
      } else {
        hintMessage = "Aucun résultat";
        removeHighlightOverlay();
      }
    } else {
      removeHighlightOverlay();
      if (widget.controler.txtControler.text.isNotEmpty &&
          widget.minCharacterNeeded > 0) {
        hintMessage =
            "${widget.minCharacterNeeded} caractère${widget.minCharacterNeeded > 1 ? 's' : ''} min.";
      } else {
        hintMessage = null;
      }
    }
    widget.controler.onInputValueChangedProcessed?.call(value);
    if (mounted) {
      setState(() {});
    }
  } */

  void onChangedTxtCompletion(String value) {
    widget.controler.selectedFromList = false;
    if (value.trim().length >= widget.minCharacterNeeded) {
      widget.controler.updateCriteria(value);
      udpateResults();
    } else {
      removeHighlightOverlay();
      if (widget.controler.txtControler.text.isNotEmpty &&
          widget.minCharacterNeeded > 0) {
        hintMessage =
            "${widget.minCharacterNeeded} caractère${widget.minCharacterNeeded > 1 ? 's' : ''} min.";
      } else {
        hintMessage = null;
      }
    }
    widget.controler.onInputValueChangedProcessed?.call(value);
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

  Future<void> udpateResults() async {
    await widget.controler.updateResultset();
    if (widget.controler.dataSourceFiltered!.isNotEmpty) {
      hintMessage = null;
      showPopup(key: textKey);
    } else {
      hintMessage = "Aucun résultat";
      removeHighlightOverlay();
    }
    _refresh();
  }

  void showPopup({required GlobalKey key}) {
    RenderBox buttonRenderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    createHighlightOverlay(
      position: buttonRenderBox.localToGlobal(Offset.zero),
    );
  }

  void removeHighlightOverlay() {
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
    removeHighlightOverlay();

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
                    widget.controler.listWidthNotifier.value ?? textFieldWidth,
                height: widget.controler.initialListHeight ?? 100,
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
                            itemCount: widget.controler.dataSourceFiltered !=
                                    null
                                ? widget.controler.dataSourceFiltered!.length
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
                                      widget.controler.onSelected?.call(widget
                                          .controler
                                          .dataSourceFiltered![index]);
                                      removeHighlightOverlay();
                                      widget.controler.selectedFromList = true;
                                      hintMessage = null;
                                      _refresh();
                                    },
                                    leading: widget
                                            .controler
                                            .dataSourceFiltered![index]
                                            .fuzzySearchResult
                                        ? Icon(
                                            Icons.help,
                                            size: 24,
                                            // les ravages de l'alcool :
                                            color: Colors.blue.withOpacity(
                                                (opa = ((widget.controler.dataSourceFiltered![
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
                                        .controler.dataSourceFiltered![index]
                                        .title(widget.controler)),
                              );
                            },
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                      ),
                      if (widget.controler.dataSourceFiltered != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Text(
                                "${widget.controler.dataSourceFiltered!.length}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "résultat${widget.controler.dataSourceFiltered!.length > 1 ? 's' : ''}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                              if (widget.controler.dataSourceFiltered!
                                      .isNotEmpty &&
                                  widget.controler.dataSourceFiltered!.first
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
                                )
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
