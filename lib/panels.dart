import 'package:flutter/material.dart';

class Panel {
  double width;
  double? _currentWidth;
  bool visible; // c'est l'état initial, cela peut être caché ensuite
  late bool displayed; // c'est l'état actuel, visible ou non
  bool noHide; // toujours visible, quelque soit l'état de visible
  int sizable; // 0: non sizable, 100: sizable. Pour les pourcentages, on verra plus tard
  Widget? child;
  int durationMilliseconds = 0;

  Panel(
      {this.width = 500,
      required this.child,
      this.visible = true,
      this.sizable = 100,
      this.noHide = false}) {
    displayed = visible;
  }
}

class PanelView extends StatelessWidget {
  const PanelView(
      {super.key,
      required this.panel,
      required this.milliseconds,
      required this.width,
      required this.isAnimating,
      required this.durationMilliseconds});

  final Panel panel;
  final int milliseconds;
  final double width;
  final bool isAnimating;
  final int durationMilliseconds;

  @override
  Widget build(BuildContext context) {
    /*int d = milliseconds;
     if (width > panel.width) {
      d = milliseconds ~/ 2;
    } else if (width < panel.width) {
      d = milliseconds * 2;
    } */
    return AnimatedContainer(
      duration: Duration(milliseconds: isAnimating ? durationMilliseconds : 0),
      curve: Curves.easeInOut,
      width: width,
      child: panel.child,
    );
  }
}

class PanelsController extends ChangeNotifier {
  List<Panel> list = [];
  int currentPanel = 0;
  int lastPanel = 0;

  double? separatorWidth;
  Widget? separator;

  final double _screenWidth = 0;

  double get screenWidth => _screenWidth;

  double totalWidth(toIndex) {
    double totalWidth = 0;

    for (int i = 0; i < toIndex; i++) {
      totalWidth += list[i].width;
      if (i == toIndex) {
        break;
      }
    }

    return totalWidth;
  }

  void setVisiblity({required int index, required bool visible}) {
    assert(index >= 0 && index < list.length);
    if (list[index].visible != visible) {
      list[index].visible = visible;
      notifyListeners();
    }
  }

  bool isVisible(int index) {
    assert(index >= 0 && index < list.length);
    return list[index].visible;
  }

  void setSeparator({required double width, required Widget separator}) {
    separatorWidth = width;
    this.separator = separator;
  }
}

// *************************************************************************
class HMultiPanels extends StatefulWidget {
  const HMultiPanels({
    super.key,
    required this.panels,
  });

  final PanelsController panels;
  @override
  State<HMultiPanels> createState() => _HMultiPanelsState();
}

class _HMultiPanelsState extends State<HMultiPanels> {
  bool _isAnimating = false;
  int milliseconds = 200;
  int modifiedList = 0; // 0; non modifié, -1: suppression, 1: ajout

  @override
  void initState() {
    super.initState();
    widget.panels.addListener(() {
      _refresh();
    });
    panelsRef.clear();
    panelsRef = widget.panels.list.map((panel) => panel.visible).toList();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  List<bool> panelsRef = [];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return StatefulBuilder(
          builder: (context, setState) {
            // pu... d'IA qui ne comprend rien de ce que je veux. J'en suis rendu à taper du code moi même :(
            // C'est moins beau, mais ça marche (ou presque)

            // on regarde ce qui doit être affiché
            double totalWidth = 0;
            for (Panel element in widget.panels.list) {
              if (element.visible &&
                  totalWidth + element.width < constraints.maxWidth) {
                element._currentWidth =
                    element.width - (widget.panels.separatorWidth ?? 0);
                element.displayed = true;
                //totalWidth += element.width;
                totalWidth += element._currentWidth!;
              } else if (element.noHide) {
                element._currentWidth =
                    element.width - (widget.panels.separatorWidth ?? 0);
                totalWidth += element._currentWidth!;
                element.displayed = true;
              } else {
                element._currentWidth = 0.0;
                element.displayed = false;
              }
            }
            for (Panel element in widget.panels.list) {
              element.durationMilliseconds = milliseconds;
              if (element._currentWidth == 0) {
                element.displayed = false;
              }
            }
            // plus rien à afficher
            if (widget.panels.list
                .where((element) => element.displayed == true)
                .isEmpty) {
              return SizedBox(
                width: constraints.maxWidth,
                child: const Center(
                  child: Text('No panel to display'),
                ),
              );
            }
            // on ajuste le dernier élément ajustable
            try {
              Panel last = widget.panels.list
                  .where((element) =>
                      element._currentWidth! != 0 && element.sizable != 0)
                  .last;
              last._currentWidth =
                  constraints.maxWidth - totalWidth + last.width;
            } catch (e) {
              debugPrint(e.toString());
            }

            // on regarde si la liste a été modifiée
            modifiedList = 0;
            if (panelsRef.length == widget.panels.list.length) {
              for (int i = 0; i < panelsRef.length; i++) {
                if (panelsRef[i] != widget.panels.list[i].displayed) {
                  if (panelsRef[i] == true) {
                    modifiedList = -1;
                    widget.panels.list[i].durationMilliseconds =
                        (milliseconds * 2).toInt();
                  } else {
                    modifiedList = 1;
                    widget.panels.list[i].durationMilliseconds = milliseconds;
                  }
                  break;
                }
              }
            }
            // on met à jour la liste de référence
            panelsRef.clear();
            panelsRef =
                widget.panels.list.map((panel) => panel.displayed).toList();

            // si la liste à été modifiée, on lance l'animation
            // quand même pratique les commentaires avec Copilot !
            if (modifiedList != 0) {
              int d = milliseconds;
              if (modifiedList > 0) {
                //print("ajout");
                //d = 0;
                _isAnimating = true;
              } else {
                //print("suppression");
                _isAnimating = true;
              }
              Future.delayed(Duration(milliseconds: d), () {
                if (mounted) {
                  setState(() {
                    _isAnimating = false;
                  });
                }
              });
            }

            return Row(
              children: [
                for (int i = 0; i < widget.panels.list.length; i++) ...[
                  PanelView(
                    panel: widget.panels.list[i],
                    milliseconds: milliseconds,
                    width: widget.panels.list[i]._currentWidth!,
                    isAnimating: _isAnimating,
                    durationMilliseconds:
                        widget.panels.list[i].durationMilliseconds,
                  ),
                  if (widget.panels.separator != null &&
                      widget.panels.list[i].displayed == true &&
                      widget.panels.list[i] !=
                          widget.panels.list
                              .where((element) => element.displayed == true)
                              .last)
                    widget.panels.separator!,
                ],
              ],
            );
          },
        );
      },
    );
  }
}
