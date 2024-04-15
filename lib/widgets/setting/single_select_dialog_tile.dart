import 'package:flutter/material.dart';
import 'package:wenku/global.dart';

class SingleSelectDialogTile extends StatefulWidget {
  final Widget title;
  final Widget leading;
  final String settingKey;
  final Map<String, String> options;
  final String defaultValue;
  final String initialValue;
  final void Function(String value)? onValueChanged;

  const SingleSelectDialogTile({
    super.key,
    required this.title,
    required this.leading,
    required this.settingKey,
    required this.options,
    required this.defaultValue,
    required this.initialValue,
    this.onValueChanged,
  });

  @override
  State<SingleSelectDialogTile> createState() => _SingleSelectDialogTileState();
}

class _SingleSelectDialogTileState extends State<SingleSelectDialogTile> {
  late String currentValue;
  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.leading,
      title: widget.title,
      subtitle: Text(widget.options[currentValue]!),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            final optionList = widget.options.entries.toList();
            return AlertDialog(
              title: widget.title,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16.0),
              content: SizedBox(
                width: double.minPositive,
                child: ListView(
                  shrinkWrap: true,
                  children: optionList.map(
                    (e) {
                      return RadioListTile(
                        value: e.key,
                        groupValue: currentValue,
                        title: Text(e.value),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              currentValue = value;
                            });
                            Global.preferences.setString(widget.settingKey, value);
                            Navigator.pop(context);

                            if (widget.onValueChanged != null) {
                              widget.onValueChanged!(value);
                            }
                          }
                        },
                      );
                    },
                  ).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("取消"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
