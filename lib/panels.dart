import 'package:flutter/material.dart';

class Panel {
  double width;
  bool visible = false;
  Widget? child;

  Panel({this.width = 500, required this.child}) {
    visible = true;
  }
}

class PanelView extends StatelessWidget {
  const PanelView(
      {super.key,
      required this.panel,
      required this.milliseconds,
      required this.width,
      required this.isAnimating});

  final Panel panel;
  final int milliseconds;
  final double width;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    int d = milliseconds;
    if (width > panel.width) {
      d = milliseconds ~/ 2;
    } else if (width < panel.width) {
      d = milliseconds * 2;
    }
    return AnimatedContainer(
      duration: Duration(milliseconds: isAnimating ? d : 0),
      curve: Curves.easeInOut,
      width: width,
      child: panel.child,
    );
  }
}

class PanelsController {
  List<Panel> list = [];
  int currentPanel = 0;
  int lastPanel = 0;

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

  int getActivePanel(double totalWidth) {
    double width = 0;
    int count = 0;
    for (Panel panel in list) {
      width += panel.width;
      if (width > totalWidth) {
        break;
      }
      count++;
    }
    return count.clamp(1, list.length);
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
  int _visibleContainers = 1;
  bool _isAnimating = false;
  int milliseconds = 200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int newVisibleContainers =
            widget.panels.getActivePanel(constraints.maxWidth);
        final bool bRemovePanel = newVisibleContainers > _visibleContainers;
        final bool bAddPanel = newVisibleContainers < _visibleContainers;

        return StatefulBuilder(
          builder: (context, setState) {
            final double totalWidth = constraints.maxWidth;
            /* final List<double> widths = List.generate(4, (index) {
              if (index < newVisibleContainers - 1) {
                return widget.panels.list[index].width;
              }
              if (index == newVisibleContainers - 1) {                
                return totalWidth -
                    widget.panels.totalWidth(newVisibleContainers - 1);
              }
              return 0.0;
            }); */

            final List<double> widths = List.generate(4, (index) {
              if (index < newVisibleContainers - 1) {
                return widget.panels.list[index].width;
              }
              if (index == newVisibleContainers - 1) {
                return totalWidth -
                    widget.panels.totalWidth(newVisibleContainers - 1);
              }
              return 0.0;
            });

            if (bAddPanel || bRemovePanel) {
              int d = milliseconds;
              if (bRemovePanel) {
                d = 0;
              }
              _isAnimating = true;
              Future.delayed(Duration(milliseconds: d), () {
                if (mounted) {
                  setState(() {
                    _isAnimating = false;
                    _visibleContainers = newVisibleContainers;
                  });
                }
              });
            }

            return Row(
              children: [
                for (int i = 0; i < widget.panels.list.length; i++)
                  PanelView(
                    panel: widget.panels.list[i],
                    milliseconds: milliseconds,
                    width: widths[i],
                    isAnimating: _isAnimating,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
