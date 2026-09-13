import 'package:flutter/material.dart';

class EditableListDropdown extends StatefulWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final ValueChanged<List<String>> onListChanged;

  const EditableListDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.onListChanged,
  });

  @override
  State<EditableListDropdown> createState() => _EditableListDropdownState();
}

class _EditableListDropdownState extends State<EditableListDropdown> {
  late List<String> _items;
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _items = List<String>.from(widget.items);
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant EditableListDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List<String>.from(widget.items);
    }
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${widget.label}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new value',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      if (!_items.contains(result)) {
        setState(() {
          _items = [..._items, result];
        });
        widget.onListChanged(_items);
      }
      setState(() => _currentValue = result);
      widget.onChanged(result);
    }
  }

  Future<void> _showManageDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Manage ${widget.label} list'),
              content: SizedBox(
                width: double.maxFinite,
                child: _items.isEmpty
                    ? const Text('List is empty')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            title: Text(item),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () {
                                setDialogState(() {
                                  _items.removeAt(index);
                                });
                                setState(() {});
                                widget.onListChanged(List.from(_items));
                                if (_currentValue == item) {
                                  setState(() => _currentValue = '');
                                  widget.onChanged('');
                                }
                              },
                            ),
                            onTap: () {
                              setState(() => _currentValue = item);
                              widget.onChanged(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add new'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveValue =
        _items.contains(_currentValue) ? _currentValue : null;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: effectiveValue,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: widget.label,
              isDense: true,
            ),
            hint: const Text('Select...'),
            items: _items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _currentValue = v);
                widget.onChanged(v);
              }
            },
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Manage list (Add / Delete)',
          onPressed: _showManageDialog,
        ),
      ],
    );
  }
}
