// ignore_for_file: file_names

//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chip_common.dart';

class ChipDateController extends ChangeNotifier {
  DateTime? _dateValue;
  DateTime? get dateValue => _dateValue;

  set dateValue(DateTime? value) {
    _dateValue = value;
    notifyListeners();
  }
}

// ignore: must_be_immutable
class ChipDate extends StatefulWidget {
  ChipDate(
      {super.key,
      required this.controller,
      this.bgColor = Colors.white,
      this.textFieldWidth = 180,
      this.emptyMessage = "Clic pour saisir",
      this.txtStyle = const TextStyle(fontWeight: FontWeight.w500),
      this.icon = Icons.help,
      this.deleteTooltipMessage = "Supprimer",
      visible = true,
      this.tooltipMessage,
      this.tooltipMessageEmpty,
      this.iconColor,
      this.removable = false,
      this.bottomMessage,
      this.disabledColor,
      this.item});

  ChipDateController? controller;
  final Color bgColor;
  final double textFieldWidth;
  final String emptyMessage;
  final TextStyle txtStyle;
  final IconData? icon;
  final String deleteTooltipMessage;
  final String? tooltipMessageEmpty;
  final String? tooltipMessage;
  final String? bottomMessage;
  final Color? iconColor;
  final Color? disabledColor;
  final bool removable;
  dynamic item;

  bool _visible = true;
  get visible => _visible;

  set visible(value) {
    _visible = value;
    _visibleNotif?.value = value;
  }

  ValueNotifier<bool?>? _visibleNotif = ValueNotifier(true);
  ValueNotifier<DateTime?>? _valueNotif = ValueNotifier(null);
  @override
  State<ChipDate> createState() => _ChipDateState();
}

class _ChipDateState extends State<ChipDate> with ChipMixin {
  @override
  void initState() {
    widget._visibleNotif?.addListener(() {
      if (mounted) {
        setState(() {}); // i refresh is date is changed
      }
    });
    widget._valueNotif?.addListener(() {
      if (mounted) {
        setState(() {}); // i refresh is date is changed
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget._visibleNotif?.dispose();
    widget._visibleNotif = null;

    widget._valueNotif?.dispose();
    widget._valueNotif = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller?.dateValue != null && widget.bottomMessage != null
        ? displayBottomMessage = true
        : displayBottomMessage = false;

    return widget._visibleNotif?.value == true
        ? Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  await _selectDate(context, widget.controller?.dateValue)
                      .then((value) {
                    setState(() {
                      if (value != null) {
                        widget.controller?.dateValue = value;
                        ChipUpdateNotification(item: widget.item)
                            .dispatch(context);
                        //setState(() {});
                        //widget.onUpdate?.call(widget.date.value);
                      }
                    });
                  });
                },
                child: Theme(
                  data: ThemeData(useMaterial3: false),
                  child: Chip(
                    elevation: 4.0,
                    visualDensity: const VisualDensity(vertical: 0),
                    backgroundColor: widget.bgColor,
                    labelPadding: const EdgeInsets.all(2.0),
                    color: WidgetStatePropertyAll(widget.bgColor),
                    deleteIconColor: Colors.grey.shade700,
                    onDeleted:
                        widget.removable || widget.controller?.dateValue != null
                            ? () {
                                if (widget.controller?.dateValue != null) {
                                  widget.controller?.dateValue = null;
                                  ChipUpdateNotification(item: widget.item)
                                      .dispatch(context);
                                  setState(() {});
                                } else {
                                  ChipDeleteNotification(item: widget.item)
                                      .dispatch(context);
                                }
                              }
                            : null,

                    //onPressed: () => _selectDate(context),

                    avatar: Icon(
                      widget.icon ?? Icons.date_range,
                      color: widget.iconColor ?? Theme.of(context).primaryColor,
                    ),
                    label: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: widget.controller?.dateValue == null
                          ? FittedBox(
                              child: Row(
                                children: [
                                  Text(
                                    widget.emptyMessage,
                                    style: TextStyle(
                                        color:
                                            widget.disabledColor ?? Colors.grey,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  SizedBox(
                                      width: widget.controller?.dateValue ==
                                                  null &&
                                              widget.removable == false
                                          ? 10
                                          : 0),
                                ],
                              ),
                            )
                          : widget.controller != null &&
                                  widget.controller!.dateValue != null
                              ? Text(DateFormat('d/M/y')
                                  .format(widget.controller!.dateValue!))
                              : const SizedBox(),
                    ),
                    //padding: const EdgeInsets.symmetric(horizontal: 0),
                  ),
                ),
              ),
              wdBottomMessage(widget.bottomMessage)
            ],
          )
        : const SizedBox();
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? date) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != date) {
      date = picked;
      return date;
    }
    return null;
  }
}
